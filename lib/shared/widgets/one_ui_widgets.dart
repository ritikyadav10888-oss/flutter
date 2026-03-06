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
      expandedHeight: expanded ? 200.0 : null,
      floating: false,
      pinned: true,
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final top = constraints.biggest.height;
          final isExpanded = top > 120;
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
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
            background: expanded
                ? Container(
                    padding: const EdgeInsets.only(top: 60),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                              title,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displayLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textDark,
                                  ),
                            )
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .scale(
                              begin: const Offset(0.9, 0.9),
                              end: const Offset(1, 1),
                            ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            subtitle!,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: AppTheme.textMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                          ).animate().fadeIn(delay: 200.ms),
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

  const OneUICard({super.key, required this.child, this.padding, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppTheme.cardPadding),
          child: child,
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
    this.showSeparator = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 12, top: 8),
            child: Text(
              title!.toUpperCase(),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppTheme.primaryIndigo,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                fontSize: 12,
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: Border.all(
              color: Colors.grey[200]!.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: AppTheme.cardShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            child: Column(
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  children[i],
                  if (showSeparator && i < children.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.grey[100],
                      indent: 16,
                      endIndent: 16,
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
        vertical: 8,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        inputFormatters: oneWordOnly
            ? [FilteringTextInputFormatter.deny(RegExp(r'\s'))]
            : null,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppTheme.textMuted.withValues(alpha: 0.6),
            fontSize: 14,
          ),
          icon: const Icon(
            Icons.search,
            color: AppTheme.primaryIndigo,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
