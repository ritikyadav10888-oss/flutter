import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AuraHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;

  final VoidCallback? onBack;

  const AuraHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isWide =
        MediaQuery.of(context).size.width >= AppTheme.mobileBreakpoint;

    return SliverAppBar(
      expandedHeight: isWide ? 180 : 140,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.backgroundWhite,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.symmetric(
          horizontal: isWide ? 40 : 24,
          vertical: 16,
        ),
        centerTitle: false,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: isWide ? 28 : 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: isWide ? 14 : 12,
                  color: AppTheme.textMuted.withOpacity(0.7),
                ),
              ),
          ],
        ),
      ),
      leading: onBack != null
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              color: AppTheme.textDark,
              onPressed: onBack,
            )
          : null,
      actions: actions,
    );
  }
}

class AuraSimpleHeader extends StatelessWidget {
  final String title;
  const AuraSimpleHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 24,
        right: 24,
        bottom: 8,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppTheme.textDark,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}

class AuraCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? color;
  final List<BoxShadow>? shadow;

  const AuraCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(AppTheme.auraPadding),
      decoration: BoxDecoration(
        color: color ?? AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        boxShadow: shadow ?? AppTheme.ambientShadow,
        border: Border.all(
          color: AppTheme.borderSoft.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}

class AuraStatsCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;

  const AuraStatsCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return AuraCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              top: -10,
              child: Icon(icon, size: 80, color: accentColor.withOpacity(0.04)),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: accentColor, size: 20),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          value,
                          style: Theme.of(context).textTheme.displayMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                height: 1,
                                fontSize: 28,
                              ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          label.toUpperCase(),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                                color: AppTheme.textMuted,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuraResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileCount;
  final int tabletCount;
  final int desktopCount;

  const AuraResponsiveGrid({
    super.key,
    required this.children,
    this.mobileCount = 1,
    this.tabletCount = 2,
    this.desktopCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    int crossAxisCount = mobileCount;
    if (width >= AppTheme.tabletBreakpoint) {
      crossAxisCount = desktopCount;
    } else if (width >= AppTheme.mobileBreakpoint) {
      crossAxisCount = tabletCount;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppTheme.auraPadding,
        mainAxisSpacing: AppTheme.auraPadding,
        childAspectRatio: crossAxisCount == 1 ? 1.8 : 1.2,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}
