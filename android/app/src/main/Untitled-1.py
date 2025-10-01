
import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import tensorflow as tf
from tensorflow.keras import layers, Model
from tensorflow.keras.applications import DenseNet201
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.callbacks import EarlyStopping, ReduceLROnPlateau, ModelCheckpoint
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from sklearn.metrics import classification_report, confusion_matrix
import warnings
warnings.filterwarnings('ignore')

# Check GPU
print("GPU Available:", len(tf.config.list_physical_devices('GPU')) > 0)

# ==============================================================================
# STEP 1: FIND THE CORRECT DATASET PATH
# ==============================================================================
def find_dataset_structure():
    """Automatically find the correct dataset structure"""
    
    base_paths = [
        '/kaggle/input/garbage-classification',
        '/kaggle/input/waste-classification-v2',
        '/kaggle/input/waste-images'
    ]
    
    dataset_info = {}
    
    for base_path in base_paths:
        if os.path.exists(base_path):
            print(f"\n📁 Found dataset at: {base_path}")
            print("Directory structure:")
            
            # Walk through directory structure
            for root, dirs, files in os.walk(base_path):
                level = root.replace(base_path, '').count(os.sep)
                indent = ' ' * 2 * level
                print(f'{indent}{os.path.basename(root)}/')
                
                # Check if this directory contains class folders
                if dirs and not files:  # Directory with subdirectories but no files
                    # Check if subdirectories contain images
                    sample_dir = os.path.join(root, dirs[0])
                    if os.path.exists(sample_dir):
                        sample_files = os.listdir(sample_dir)
                        if any(f.endswith(('.jpg', '.jpeg', '.png')) for f in sample_files[:5]):
                            dataset_info['data_dir'] = root
                            dataset_info['classes'] = dirs
                            print(f"\n✅ Found data directory: {root}")
                            print(f"✅ Found {len(dirs)} classes: {dirs[:5]}...")
                            return dataset_info
                
                # Limit display depth
                if level > 3:
                    break
    
    return dataset_info

# Find the dataset
dataset_info = find_dataset_structure()

if not dataset_info:
    print("❌ No valid dataset structure found!")
else:
    DATA_DIR = dataset_info['data_dir']
    print(f"\n📊 Using data directory: {DATA_DIR}")

# ==============================================================================
# SQUEEZE AND EXCITATION BLOCK
# ==============================================================================
class SqueezeExcitation(layers.Layer):
    def __init__(self, filters, reduction_ratio=16, **kwargs):
        super().__init__(**kwargs)
        self.filters = filters
        self.reduction_ratio = reduction_ratio
        
    def build(self, input_shape):
        self.global_avg_pool = layers.GlobalAveragePooling2D()
        self.dense1 = layers.Dense(self.filters // self.reduction_ratio, activation='relu')
        self.dense2 = layers.Dense(self.filters, activation='sigmoid')
        self.reshape = layers.Reshape((1, 1, self.filters))
        
    def call(self, inputs):
        squeeze = self.global_avg_pool(inputs)
        excitation = self.dense1(squeeze)
        excitation = self.dense2(excitation)
        excitation = self.reshape(excitation)
        return layers.multiply([inputs, excitation])

# ==============================================================================
# MODEL ARCHITECTURE
# ==============================================================================
def create_model(num_classes, input_shape=(224, 224, 3)):
    """Create DenseNet201 with SE Attention"""
    
    inputs = layers.Input(shape=input_shape)
    
    # Base model
    base_model = DenseNet201(weights='imagenet', include_top=False, input_tensor=inputs)
    
    # Freeze early layers
    for layer in base_model.layers[:-30]:
        layer.trainable = False
    
    # Get features
    features = base_model.output
    
    # Add SE attention
    se_features = SqueezeExcitation(features.shape[-1])(features)
    
    # Global pooling
    pooled = layers.GlobalAveragePooling2D()(se_features)
    
    # Classification head
    x = layers.Dense(512, activation='relu')(pooled)
    x = layers.BatchNormalization()(x)
    x = layers.Dropout(0.5)(x)
    x = layers.Dense(256, activation='relu')(x)
    x = layers.BatchNormalization()(x)
    x = layers.Dropout(0.3)(x)
    outputs = layers.Dense(num_classes, activation='softmax')(x)
    
    model = Model(inputs=inputs, outputs=outputs, name='DenseNet_SE_Waste')
    return model

# ==============================================================================
# DATA PREPARATION WITH TRAIN/VAL SPLIT
# ==============================================================================
def prepare_data_with_split(data_dir, batch_size=32, validation_split=0.2):
    """Prepare data generators with train/validation split from single directory"""
    
    print(f"\n📂 Preparing data from: {data_dir}")
    
    # Check if we have separate TRAIN/TEST directories
    train_dir = os.path.join(data_dir, 'TRAIN')
    test_dir = os.path.join(data_dir, 'TEST')
    
    if os.path.exists(train_dir) and os.path.exists(test_dir):
        # Use existing TRAIN/TEST split
        print("Found TRAIN/TEST directories")
        use_train_dir = train_dir
        use_test_dir = test_dir
        has_test = True
    else:
        # Use the main directory for both
        print("Using single directory with validation split")
        use_train_dir = data_dir
        use_test_dir = None
        has_test = False
    
    # Data augmentation for training
    train_datagen = ImageDataGenerator(
        rescale=1./255,
        rotation_range=30,
        width_shift_range=0.2,
        height_shift_range=0.2,
        shear_range=0.2,
        zoom_range=0.2,
        horizontal_flip=True,
        validation_split=validation_split if not has_test else 0
    )
    
    # Only rescaling for validation/test
    val_datagen = ImageDataGenerator(
        rescale=1./255,
        validation_split=validation_split if not has_test else 0
    )
    
    test_datagen = ImageDataGenerator(rescale=1./255)
    
    # Training generator
    train_generator = train_datagen.flow_from_directory(
        use_train_dir,
        target_size=(224, 224),
        batch_size=batch_size,
        class_mode='categorical',
        subset='training' if not has_test else None,
        shuffle=True
    )
    
    # Validation generator
    if has_test:
        # If we have separate test dir, create val from train
        val_generator = val_datagen.flow_from_directory(
            use_train_dir,
            target_size=(224, 224),
            batch_size=batch_size,
            class_mode='categorical',
            shuffle=False
        )
        # Use test dir for testing
        test_generator = test_datagen.flow_from_directory(
            use_test_dir,
            target_size=(224, 224),
            batch_size=batch_size,
            class_mode='categorical',
            shuffle=False
        )
    else:
        # Create validation split from training data
        val_generator = val_datagen.flow_from_directory(
            use_train_dir,
            target_size=(224, 224),
            batch_size=batch_size,
            class_mode='categorical',
            subset='validation',
            shuffle=False
        )
        test_generator = None
    
    return train_generator, val_generator, test_generator

# ==============================================================================
# TRAINING
# ==============================================================================
def train_model(model, train_gen, val_gen, epochs=30):
    """Train the model"""
    
    # Compile
    model.compile(
        optimizer=Adam(learning_rate=0.0001),
        loss='categorical_crossentropy',
        metrics=['accuracy', 
                tf.keras.metrics.Precision(name='precision'),
                tf.keras.metrics.Recall(name='recall')]
    )
    
    # Callbacks
    callbacks = [
        ModelCheckpoint('/kaggle/working/best_model.h5', 
                       monitor='val_accuracy', 
                       save_best_only=True, 
                       verbose=1),
        EarlyStopping(monitor='val_accuracy', patience=10, restore_best_weights=True),
        ReduceLROnPlateau(monitor='val_loss', factor=0.5, patience=5, min_lr=1e-7, verbose=1)
    ]
    
    # Train
    history = model.fit(
        train_gen,
        epochs=epochs,
        validation_data=val_gen,
        callbacks=callbacks,
        verbose=1
    )
    
    return history

# ==============================================================================
# EVALUATION
# ==============================================================================
def evaluate_model(model, test_gen, class_names):
    """Evaluate the model"""
    
    if test_gen is None:
        print("No separate test data available")
        return
    
    print("\n🔍 Evaluating model on test set...")
    
    # Get predictions
    predictions = model.predict(test_gen)
    y_pred = np.argmax(predictions, axis=1)
    y_true = test_gen.classes
    
    # Classification report
    print("\n" + "="*60)
    print("CLASSIFICATION REPORT")
    print("="*60)
    report = classification_report(y_true, y_pred, target_names=class_names, output_dict=True)
    report_df = pd.DataFrame(report).transpose()
    print(report_df)
    
    # Save report
    report_df.to_csv('/kaggle/working/classification_report.csv')
    
    # Confusion matrix
    cm = confusion_matrix(y_true, y_pred)
    
    # Plot confusion matrix
    plt.figure(figsize=(14, 12))
    sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', 
               xticklabels=class_names, yticklabels=class_names)
    plt.title('Confusion Matrix', fontsize=16)
    plt.ylabel('True Label')
    plt.xlabel('Predicted Label')
    plt.xticks(rotation=45, ha='right')
    plt.tight_layout()
    plt.savefig('/kaggle/working/confusion_matrix.png', dpi=300, bbox_inches='tight')
    plt.show()
    
    # Calculate accuracy
    accuracy = np.sum(y_pred == y_true) / len(y_true)
    print(f"\n📊 Test Accuracy: {accuracy:.4f}")
    
    return accuracy

# ==============================================================================
# PLOT TRAINING HISTORY
# ==============================================================================
def plot_history(history):
    """Plot training history"""
    
    fig, axes = plt.subplots(2, 2, figsize=(15, 10))
    
    # Accuracy
    axes[0, 0].plot(history.history['accuracy'], label='Training')
    axes[0, 0].plot(history.history['val_accuracy'], label='Validation')
    axes[0, 0].set_title('Model Accuracy')
    axes[0, 0].set_xlabel('Epoch')
    axes[0, 0].set_ylabel('Accuracy')
    axes[0, 0].legend()
    axes[0, 0].grid(True)
    
    # Loss
    axes[0, 1].plot(history.history['loss'], label='Training')
    axes[0, 1].plot(history.history['val_loss'], label='Validation')
    axes[0, 1].set_title('Model Loss')
    axes[0, 1].set_xlabel('Epoch')
    axes[0, 1].set_ylabel('Loss')
    axes[0, 1].legend()
    axes[0, 1].grid(True)
    
    # Precision
    if 'precision' in history.history:
        axes[1, 0].plot(history.history['precision'], label='Training')
        axes[1, 0].plot(history.history['val_precision'], label='Validation')
        axes[1, 0].set_title('Model Precision')
        axes[1, 0].set_xlabel('Epoch')
        axes[1, 0].set_ylabel('Precision')
        axes[1, 0].legend()
        axes[1, 0].grid(True)
    
    # Recall
    if 'recall' in history.history:
        axes[1, 1].plot(history.history['recall'], label='Training')
        axes[1, 1].plot(history.history['val_recall'], label='Validation')
        axes[1, 1].set_title('Model Recall')
        axes[1, 1].set_xlabel('Epoch')
        axes[1, 1].set_ylabel('Recall')
        axes[1, 1].legend()
        axes[1, 1].grid(True)
    
    plt.tight_layout()
    plt.savefig('/kaggle/working/training_history.png', dpi=300, bbox_inches='tight')
    plt.show()

# ==============================================================================
# MAIN EXECUTION
# ==============================================================================
def main():
    """Main execution function"""
    
    print("="*60)
    print("WASTE CLASSIFICATION WITH DENSENET201-SE")
    print("="*60)
    
    # Check if we found a valid dataset
    if not dataset_info or 'data_dir' not in dataset_info:
        print("\n❌ ERROR: No valid dataset found!")
        print("Please add one of these datasets to your notebook:")
        print("• garbage-classification")
        print("• waste-classification-v2")
        print("• waste-images")
        return
    
    # Prepare data
    print("\n📁 Preparing data...")
    train_gen, val_gen, test_gen = prepare_data_with_split(DATA_DIR, batch_size=32)
    
    # Get number of classes
    num_classes = train_gen.num_classes
    class_names = list(train_gen.class_indices.keys())
    
    print(f"\n📊 Dataset Information:")
    print(f"Number of classes: {num_classes}")
    print(f"Classes: {class_names}")
    print(f"Training samples: {train_gen.samples}")
    print(f"Validation samples: {val_gen.samples}")
    if test_gen:
        print(f"Test samples: {test_gen.samples}")
    
    # Create model
    print("\n🏗️ Building model...")
    model = create_model(num_classes)
    print(f"Total parameters: {model.count_params():,}")
    
    # Train model
    print("\n🚀 Starting training...")
    history = train_model(model, train_gen, val_gen, epochs=30)
    
    # Plot training history
    print("\n📊 Plotting training history...")
    plot_history(history)
    
    # Evaluate on test set
    if test_gen:
        evaluate_model(model, test_gen, class_names)
    
    # Save final model
    print("\n💾 Saving final model...")
    model.save('/kaggle/working/densenet_se_waste_classifier.h5')
    
    print("\n✅ Training completed successfully!")
    print("📁 Output files saved in /kaggle/working/")
    print("\nFiles created:")
    print("• best_model.h5 - Best model during training")
    print("• densenet_se_waste_classifier.h5 - Final model")
    print("• training_history.png - Training curves")
    if test_gen:
        print("• confusion_matrix.png - Confusion matrix")
        print("• classification_report.csv - Detailed metrics")

# ==============================================================================
# RUN THE TRAINING
# ==============================================================================
if __name__ == "__main__":
    main()