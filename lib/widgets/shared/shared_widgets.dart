import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design_tokens.dart';

// ============================================================================
// ATOMIC COMPONENTS
// ============================================================================

/// Primary button with consistent styling
class WastewisePrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fullWidth;
  final Widget? icon;
  final double? width;
  final double? height;

  const WastewisePrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.fullWidth = false,
    this.icon,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SizedBox(
      width: fullWidth ? double.infinity : width,
      height: height ?? DesignTokens.buttonHeight,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          disabledBackgroundColor: DesignTokens.gray300,
          disabledForegroundColor: DesignTokens.gray500,
          shape: RoundedRectangleBorder(
            borderRadius: DesignTokens.borderRadiusFull,
          ),
          padding: DesignTokens.buttonPadding,
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                height: DesignTokens.iconMD,
                width: DesignTokens.iconMD,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.onPrimary,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon!,
                    SizedBox(width: DesignTokens.space8),
                  ],
                  Text(
                    text,
                    style: GoogleFonts.inter(
                      fontSize: DesignTokens.titleMedium.fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Secondary button with outline styling
class WastewiseSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fullWidth;
  final Widget? icon;
  final double? width;
  final double? height;

  const WastewiseSecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.fullWidth = false,
    this.icon,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SizedBox(
      width: fullWidth ? double.infinity : width,
      height: height ?? DesignTokens.buttonHeight,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
          side: BorderSide(
            color: theme.colorScheme.primary,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: DesignTokens.borderRadiusFull,
          ),
          padding: DesignTokens.buttonPadding,
        ),
        child: isLoading
            ? SizedBox(
                height: DesignTokens.iconMD,
                width: DesignTokens.iconMD,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon!,
                    SizedBox(width: DesignTokens.space8),
                  ],
                  Text(
                    text,
                    style: GoogleFonts.inter(
                      fontSize: DesignTokens.titleMedium.fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Custom text button
class WastewiseTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;

  const WastewiseTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.textColor,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textColor ?? theme.colorScheme.primary,
        padding: DesignTokens.paddingSM,
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: fontSize ?? DesignTokens.bodyMedium.fontSize,
          fontWeight: fontWeight ?? FontWeight.w600,
          color: textColor ?? theme.colorScheme.primary,
        ),
      ),
    );
  }
}

/// Input field with icon support
class WastewiseTextField extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;
  final int maxLines;

  const WastewiseTextField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.maxLines = 1,
  });

  @override
  State<WastewiseTextField> createState() => _WastewiseTextFieldState();
}

class _WastewiseTextFieldState extends State<WastewiseTextField> {
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: GoogleFonts.inter(
            fontSize: DesignTokens.titleSmall.fontSize,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: DesignTokens.space8),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          onChanged: widget.onChanged,
          enabled: widget.enabled,
          maxLines: widget.maxLines,
          style: GoogleFonts.inter(
            fontSize: DesignTokens.bodyMedium.fontSize,
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : widget.suffixIcon,
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: DesignTokens.borderRadiusLG,
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: DesignTokens.borderRadiusLG,
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: DesignTokens.borderRadiusLG,
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: DesignTokens.borderRadiusLG,
              borderSide: BorderSide(color: theme.colorScheme.error),
            ),
            contentPadding: DesignTokens.inputPadding,
          ),
        ),
      ],
    );
  }
}

/// Avatar with consistent sizing
class WastewiseAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? initials;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;

  const WastewiseAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.size = DesignTokens.avatarMD,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: backgroundColor ?? theme.colorScheme.primaryContainer,
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      child: imageUrl == null && initials != null
          ? Text(
              initials!,
              style: GoogleFonts.inter(
                fontSize: size * 0.4,
                fontWeight: FontWeight.w600,
                color: textColor ?? theme.colorScheme.onPrimaryContainer,
              ),
            )
          : null,
    );
  }
}

/// Loading indicator
class WastewiseLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const WastewiseLoadingIndicator({
    super.key,
    this.size = DesignTokens.iconLG,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        color: color ?? theme.colorScheme.primary,
        strokeWidth: 2,
      ),
    );
  }
}

// ============================================================================
// MOLECULAR COMPONENTS
// ============================================================================

/// Card component with consistent styling
class WastewiseCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double? elevation;
  final Color? backgroundColor;
  final List<BoxShadow>? shadows;

  const WastewiseCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.elevation,
    this.backgroundColor,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: margin ?? DesignTokens.cardMargin,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        borderRadius: DesignTokens.borderRadiusMD,
        boxShadow: shadows ?? DesignTokens.shadowMD,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: DesignTokens.borderRadiusMD,
          child: Padding(
            padding: padding ?? DesignTokens.cardPadding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Info card with icon and text
class WastewiseInfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  const WastewiseInfoCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return WastewiseCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: DesignTokens.paddingSM,
            decoration: BoxDecoration(
              color: (iconColor ?? theme.colorScheme.primary).withValues(alpha: 0.1),
              borderRadius: DesignTokens.borderRadiusSM,
            ),
            child: Icon(
              icon,
              color: iconColor ?? theme.colorScheme.primary,
              size: DesignTokens.iconMD,
            ),
          ),
          SizedBox(width: DesignTokens.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: DesignTokens.titleMedium.fontSize,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Flexible(
                  child: Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: DesignTokens.bodySmall.fontSize,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(
              Icons.arrow_forward_ios,
              size: DesignTokens.iconSM,
              color: theme.colorScheme.onSurfaceVariant,
            ),
        ],
      ),
    );
  }
}

/// Progress card showing achievements or stats
class WastewiseProgressCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final double progress;
  final Color? progressColor;
  final Widget? icon;

  const WastewiseProgressCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.progress,
    this.progressColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return WastewiseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                icon!,
                SizedBox(width: DesignTokens.space8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: DesignTokens.titleSmall.fontSize,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: DesignTokens.space8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: DesignTokens.displaySmall.fontSize,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          SizedBox(height: DesignTokens.space4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: DesignTokens.bodySmall.fontSize,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          SizedBox(height: DesignTokens.space12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              progressColor ?? theme.colorScheme.primary,
            ),
            borderRadius: DesignTokens.borderRadiusSM,
            minHeight: 6,
          ),
        ],
      ),
    );
  }
}

/// Rating stars widget
class WastewiseRatingStars extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;

  const WastewiseRatingStars({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = DesignTokens.iconSM,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = activeColor ?? DesignTokens.accentYellow;
    final inactive = inactiveColor ?? theme.colorScheme.outline;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        maxRating,
        (index) {
          double starValue = rating - index;
          if (starValue >= 1.0) {
            return Icon(Icons.star, size: size, color: active);
          } else if (starValue >= 0.5) {
            return Icon(Icons.star_half, size: size, color: active);
          } else {
            return Icon(Icons.star_outline, size: size, color: inactive);
          }
        },
      ),
    );
  }
}

/// Tag/Chip component
class WastewiseTag extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isSelected;
  final VoidCallback? onTap;
  final Widget? icon;

  const WastewiseTag({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.isSelected = false,
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.space12,
          vertical: DesignTokens.space8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
          borderRadius: DesignTokens.borderRadiusFull,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon!,
              SizedBox(width: DesignTokens.space4),
            ],
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: DesignTokens.labelMedium.fontSize,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : textColor ?? theme.colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state widget
class WastewiseEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;

  const WastewiseEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: DesignTokens.paddingXL,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: DesignTokens.iconXL * 2,
              color: theme.colorScheme.outline,
            ),
            SizedBox(height: DesignTokens.space24),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: DesignTokens.headlineSmall.fontSize,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            SizedBox(height: DesignTokens.space8),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: DesignTokens.bodyMedium.fontSize,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 4,
            ),
            if (actionText != null && onAction != null) ...[
              SizedBox(height: DesignTokens.space24),
              WastewisePrimaryButton(
                text: actionText!,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
