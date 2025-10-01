import 'package:flutter/material.dart';
import '../core/design_tokens.dart';

/// Material 3 Components Showcase
/// Demonstrates proper usage of Material 3 widgets
/// Based on https://docs.flutter.dev/ui/widgets/material
class Material3Showcase extends StatefulWidget {
  const Material3Showcase({super.key});

  @override
  State<Material3Showcase> createState() => _Material3ShowcaseState();
}

class _Material3ShowcaseState extends State<Material3Showcase> {
  int _selectedIndex = 0;
  bool _switchValue = false;
  bool _checkboxValue = false;
  double _sliderValue = 50;
  int _selectedSegment = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Material 3 Components'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: DesignTokens.paddingMD,
        children: [
          // Buttons Section
          _buildSection(
            context,
            'Buttons',
            [
              // Filled Button (Primary)
              FilledButton(
                onPressed: () {},
                child: const Text('Filled Button'),
              ),
              const SizedBox(width: 8),
              
              // Filled Tonal Button
              FilledButton.tonal(
                onPressed: () {},
                child: const Text('Filled Tonal'),
              ),
              const SizedBox(width: 8),
              
              // Elevated Button
              ElevatedButton(
                onPressed: () {},
                child: const Text('Elevated'),
              ),
              const SizedBox(width: 8),
              
              // Outlined Button
              OutlinedButton(
                onPressed: () {},
                child: const Text('Outlined'),
              ),
              const SizedBox(width: 8),
              
              // Text Button
              TextButton(
                onPressed: () {},
                child: const Text('Text Button'),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Icon Buttons Section
          _buildSection(
            context,
            'Icon Buttons',
            [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.favorite_border),
              ),
              IconButton.filled(
                onPressed: () {},
                icon: const Icon(Icons.favorite),
              ),
              IconButton.filledTonal(
                onPressed: () {},
                icon: const Icon(Icons.favorite),
              ),
              IconButton.outlined(
                onPressed: () {},
                icon: const Icon(Icons.favorite_border),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // FAB Section
          _buildSection(
            context,
            'Floating Action Buttons',
            [
              FloatingActionButton(
                onPressed: () {},
                child: const Icon(Icons.add),
              ),
              const SizedBox(width: 8),
              FloatingActionButton.small(
                onPressed: () {},
                child: const Icon(Icons.add),
              ),
              const SizedBox(width: 8),
              FloatingActionButton.extended(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Extended FAB'),
              ),
              const SizedBox(width: 8),
              FloatingActionButton.large(
                onPressed: () {},
                child: const Icon(Icons.add),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Cards Section
          _buildSectionColumn(
            context,
            'Cards',
            [
              // Elevated Card
              Card(
                child: Padding(
                  padding: DesignTokens.paddingMD,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Elevated Card',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This is an elevated card with default elevation.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Filled Card
              Card(
                elevation: 0,
                color: colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: DesignTokens.paddingMD,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filled Card',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This is a filled card with surface color.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Outlined Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: DesignTokens.borderRadiusMD,
                  side: BorderSide(color: colorScheme.outline),
                ),
                child: Padding(
                  padding: DesignTokens.paddingMD,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Outlined Card',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This is an outlined card with a border.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Chips Section
          _buildSection(
            context,
            'Chips',
            [
              FilterChip(
                label: const Text('Filter Chip'),
                selected: true,
                onSelected: (value) {},
              ),
              const SizedBox(width: 8),
              InputChip(
                label: const Text('Input Chip'),
                onDeleted: () {},
              ),
              const SizedBox(width: 8),
              ActionChip(
                label: const Text('Action Chip'),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Choice Chip'),
                selected: false,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Switches and Checkboxes
          _buildSectionColumn(
            context,
            'Selection Controls',
            [
              SwitchListTile(
                title: const Text('Switch'),
                subtitle: const Text('Toggle me'),
                value: _switchValue,
                onChanged: (value) {
                  setState(() {
                    _switchValue = value;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Checkbox'),
                subtitle: const Text('Check me'),
                value: _checkboxValue,
                onChanged: (value) {
                  setState(() {
                    _checkboxValue = value ?? false;
                  });
                },
              ),
              RadioListTile<int>(
                title: const Text('Radio Button 1'),
                value: 0,
                groupValue: _selectedSegment,
                onChanged: (value) {
                  setState(() {
                    _selectedSegment = value ?? 0;
                  });
                },
              ),
              RadioListTile<int>(
                title: const Text('Radio Button 2'),
                value: 1,
                groupValue: _selectedSegment,
                onChanged: (value) {
                  setState(() {
                    _selectedSegment = value ?? 0;
                  });
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Slider
          _buildSectionColumn(
            context,
            'Slider',
            [
              Slider(
                value: _sliderValue,
                min: 0,
                max: 100,
                divisions: 10,
                label: _sliderValue.round().toString(),
                onChanged: (value) {
                  setState(() {
                    _sliderValue = value;
                  });
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Progress Indicators
          _buildSection(
            context,
            'Progress Indicators',
            [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  value: _sliderValue / 100,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Badges
          _buildSection(
            context,
            'Badges',
            [
              Badge(
                label: const Text('5'),
                child: IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 16),
              Badge(
                child: IconButton(
                  icon: const Icon(Icons.mail),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Segmented Button
          _buildSectionColumn(
            context,
            'Segmented Button',
            [
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(
                    value: 0,
                    label: Text('Day'),
                    icon: Icon(Icons.wb_sunny),
                  ),
                  ButtonSegment(
                    value: 1,
                    label: Text('Week'),
                    icon: Icon(Icons.calendar_today),
                  ),
                  ButtonSegment(
                    value: 2,
                    label: Text('Month'),
                    icon: Icon(Icons.calendar_month),
                  ),
                ],
                selected: {_selectedSegment},
                onSelectionChanged: (Set<int> newSelection) {
                  setState(() {
                    _selectedSegment = newSelection.first;
                  });
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Text Fields
          _buildSectionColumn(
            context,
            'Text Fields',
            [
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Filled TextField',
                  hintText: 'Enter text',
                  prefixIcon: Icon(Icons.person),
                  filled: true,
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Outlined TextField',
                  hintText: 'Enter text',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Search Bar
          _buildSectionColumn(
            context,
            'Search Bar',
            [
              SearchBar(
                leading: const Icon(Icons.search),
                hintText: 'Search...',
                trailing: [
                  IconButton(
                    icon: const Icon(Icons.mic),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 80),
        ],
      ),
      
      // Navigation Bar (Material 3)
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      
      // FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showMaterial3Dialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: children,
        ),
      ],
    );
  }
  
  Widget _buildSectionColumn(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }
  
  void _showMaterial3Dialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.info_outline),
        title: const Text('Material 3 Dialog'),
        content: const Text(
          'This is a Material 3 dialog with rounded corners and proper styling.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// Material 3 List Tile Examples
class Material3ListTileExample extends StatelessWidget {
  const Material3ListTileExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('List Tiles')),
      body: ListView(
        children: [
          // One-line list tile
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: const Text('One-line list tile'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
          
          // Two-line list tile
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Two-line list tile'),
            subtitle: const Text('Supporting text'),
            trailing: const Icon(Icons.star),
            onTap: () {},
          ),
          
          // Three-line list tile
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Three-line list tile'),
            subtitle: const Text(
              'This is supporting text that spans multiple lines to demonstrate three-line list tiles.',
            ),
            isThreeLine: true,
            trailing: const Icon(Icons.more_vert),
            onTap: () {},
          ),
          
          const Divider(),
          
          // Switch list tile
          SwitchListTile(
            secondary: const Icon(Icons.wifi),
            title: const Text('Wi-Fi'),
            subtitle: const Text('Connected to network'),
            value: true,
            onChanged: (value) {},
          ),
          
          // Checkbox list tile
          CheckboxListTile(
            secondary: const Icon(Icons.location_on),
            title: const Text('Location Services'),
            subtitle: const Text('Allow apps to access location'),
            value: true,
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }
}

/// Material 3 Navigation Examples
class Material3NavigationExample extends StatefulWidget {
  const Material3NavigationExample({super.key});

  @override
  State<Material3NavigationExample> createState() => _Material3NavigationExampleState();
}

class _Material3NavigationExampleState extends State<Material3NavigationExample> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigation')),
      body: Row(
        children: [
          // Navigation Rail (for wider screens)
          if (MediaQuery.of(context).size.width > 600)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.explore_outlined),
                  selectedIcon: Icon(Icons.explore),
                  label: Text('Explore'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: Text('Profile'),
                ),
              ],
            ),
          
          // Content area
          Expanded(
            child: Center(
              child: Text(
                'Selected: $_selectedIndex',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Text(
                'Drawer Header',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {},
            ),
          ],
        ),
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width <= 600
          ? NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.explore_outlined),
                  selectedIcon: Icon(Icons.explore),
                  label: 'Explore',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            )
          : null,
    );
  }
}
