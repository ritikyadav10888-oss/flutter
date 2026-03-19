import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';

class OneUIResponsivePadding extends StatelessWidget {
  final Widget child;
  final bool maxWidth;

  const OneUIResponsivePadding({
    super.key,
    required this.child,
    this.maxWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth ? AppTheme.maxContentWidth : double.infinity,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: child,
      ),
    );
  }
}

class OneUIHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const OneUIHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryIndigo,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 14, color: AppTheme.textMuted),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class OneUISliverHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool expanded;

  const OneUISliverHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: expanded ? 220.0 : null,
      floating: false,
      pinned: true,
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppTheme.backgroundWhite,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final top = constraints.biggest.height;
          final isExpanded = top > 130;
          final opacity = isExpanded ? 0.0 : 1.0;

          return FlexibleSpaceBar(
            centerTitle: true,
            titlePadding: const EdgeInsets.only(
              bottom: 16,
              left: 16,
              right: 16,
            ),
            title: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: opacity,
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: AppTheme.textDark,
                ),
              ),
            ),
            background: expanded
                ? Container(
                    decoration: const BoxDecoration(
                      color: AppTheme.backgroundWhite,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Text(
                              title,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displayLarge
                                  ?.copyWith(color: AppTheme.textDark),
                            )
                            .animate()
                            .fadeIn(duration: 500.ms)
                            .moveY(
                              begin: 20,
                              end: 0,
                              curve: Curves.easeOutCirc,
                            ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            subtitle!,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: AppTheme.textMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                          ).animate().fadeIn(delay: 300.ms),
                        ],
                      ],
                    ),
                  )
                : null,
          );
        },
      ),
      actions: actions,
    );
  }
}

class OneUICard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool useGlass;

  const OneUICard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.useGlass = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.borderLight, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppTheme.cardPadding),
            child: child,
          ),
        ),
      ),
    );
  }
}

class OneUISection extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  final bool showSeparator;

  const OneUISection({
    super.key,
    this.title,
    required this.children,
    this.showSeparator = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 12, top: 16),
            child: Text(
              title!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textDark,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.backgroundWhite,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: Border.all(color: AppTheme.borderLight, width: 1),
            boxShadow: AppTheme.cardShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            child: Column(
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  children[i],
                  if (showSeparator && i < children.length - 1)
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppTheme.borderLight,
                      indent: 20,
                      endIndent: 20,
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class OneUISearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onChanged;
  final bool oneWordOnly;

  const OneUISearchBar({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.oneWordOnly = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.sectionSpacing,
        vertical: 12,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGrey,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.softShadow,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        inputFormatters: oneWordOnly
            ? [FilteringTextInputFormatter.deny(RegExp(r'\s'))]
            : null,
        style: const TextStyle(
          color: AppTheme.textDark,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppTheme.textMuted.withValues(alpha: 0.6),
            fontSize: 15,
          ),
          icon: const Icon(
            Icons.search_rounded,
            color: AppTheme.primaryIndigo,
            size: 22,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
