import 'package:flutter/material.dart';

/// Responsive utility class for handling different screen sizes
class Responsive {
  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  static const double largeDesktopBreakpoint = 1600;

  /// Get screen type based on width
  static ScreenType getScreenType(double width) {
    if (width < mobileBreakpoint) {
      return ScreenType.mobile;
    } else if (width < tabletBreakpoint) {
      return ScreenType.tablet;
    } else if (width < desktopBreakpoint) {
      return ScreenType.desktop;
    } else {
      return ScreenType.largeDesktop;
    }
  }

  /// Check if current screen is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Check if current screen is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  /// Check if current screen is desktop
  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tabletBreakpoint && width < desktopBreakpoint;
  }

  /// Check if current screen is large desktop
  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final screenType = getScreenType(MediaQuery.of(context).size.width);
    switch (screenType) {
      case ScreenType.mobile:
        return const EdgeInsets.all(16);
      case ScreenType.tablet:
        return const EdgeInsets.all(24);
      case ScreenType.desktop:
        return const EdgeInsets.all(32);
      case ScreenType.largeDesktop:
        return const EdgeInsets.all(40);
    }
  }

  /// Get responsive margin based on screen size
  static EdgeInsets getResponsiveMargin(BuildContext context) {
    final screenType = getScreenType(MediaQuery.of(context).size.width);
    switch (screenType) {
      case ScreenType.mobile:
        return const EdgeInsets.all(8);
      case ScreenType.tablet:
        return const EdgeInsets.all(12);
      case ScreenType.desktop:
        return const EdgeInsets.all(16);
      case ScreenType.largeDesktop:
        return const EdgeInsets.all(20);
    }
  }

  /// Get responsive font size
  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    final screenType = getScreenType(MediaQuery.of(context).size.width);
    switch (screenType) {
      case ScreenType.mobile:
        return baseFontSize;
      case ScreenType.tablet:
        return baseFontSize * 1.1;
      case ScreenType.desktop:
        return baseFontSize * 1.2;
      case ScreenType.largeDesktop:
        return baseFontSize * 1.3;
    }
  }

  /// Get responsive icon size
  static double getResponsiveIconSize(BuildContext context, double baseIconSize) {
    final screenType = getScreenType(MediaQuery.of(context).size.width);
    switch (screenType) {
      case ScreenType.mobile:
        return baseIconSize;
      case ScreenType.tablet:
        return baseIconSize * 1.2;
      case ScreenType.desktop:
        return baseIconSize * 1.4;
      case ScreenType.largeDesktop:
        return baseIconSize * 1.6;
    }
  }

  /// Get responsive grid columns
  static int getResponsiveGridColumns(BuildContext context) {
    final screenType = getScreenType(MediaQuery.of(context).size.width);
    switch (screenType) {
      case ScreenType.mobile:
        return 1;
      case ScreenType.tablet:
        return 2;
      case ScreenType.desktop:
        return 3;
      case ScreenType.largeDesktop:
        return 4;
    }
  }

  /// Get responsive card width
  static double getResponsiveCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenType = getScreenType(screenWidth);
    
    switch (screenType) {
      case ScreenType.mobile:
        return screenWidth - 32; // Full width minus padding
      case ScreenType.tablet:
        return (screenWidth - 48) / 2; // Half width minus padding
      case ScreenType.desktop:
        return (screenWidth - 64) / 3; // Third width minus padding
      case ScreenType.largeDesktop:
        return (screenWidth - 80) / 4; // Quarter width minus padding
    }
  }

  /// Get responsive sidebar width
  static double getResponsiveSidebarWidth(BuildContext context) {
    final screenType = getScreenType(MediaQuery.of(context).size.width);
    switch (screenType) {
      case ScreenType.mobile:
        return 0; // No sidebar on mobile
      case ScreenType.tablet:
        return 200;
      case ScreenType.desktop:
        return 250;
      case ScreenType.largeDesktop:
        return 300;
    }
  }

  /// Get responsive max content width
  static double getResponsiveMaxContentWidth(BuildContext context) {
    final screenType = getScreenType(MediaQuery.of(context).size.width);
    switch (screenType) {
      case ScreenType.mobile:
        return double.infinity; // Full width
      case ScreenType.tablet:
        return 800;
      case ScreenType.desktop:
        return 1200;
      case ScreenType.largeDesktop:
        return 1400;
    }
  }

  /// Get responsive spacing
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    final screenType = getScreenType(MediaQuery.of(context).size.width);
    switch (screenType) {
      case ScreenType.mobile:
        return baseSpacing;
      case ScreenType.tablet:
        return baseSpacing * 1.2;
      case ScreenType.desktop:
        return baseSpacing * 1.5;
      case ScreenType.largeDesktop:
        return baseSpacing * 1.8;
    }
  }

  /// Get responsive button height
  static double getResponsiveButtonHeight(BuildContext context) {
    final screenType = getScreenType(MediaQuery.of(context).size.width);
    switch (screenType) {
      case ScreenType.mobile:
        return 48;
      case ScreenType.tablet:
        return 52;
      case ScreenType.desktop:
        return 56;
      case ScreenType.largeDesktop:
        return 60;
    }
  }

  /// Get responsive app bar height
  static double getResponsiveAppBarHeight(BuildContext context) {
    final screenType = getScreenType(MediaQuery.of(context).size.width);
    switch (screenType) {
      case ScreenType.mobile:
        return kToolbarHeight;
      case ScreenType.tablet:
        return kToolbarHeight + 8;
      case ScreenType.desktop:
        return kToolbarHeight + 16;
      case ScreenType.largeDesktop:
        return kToolbarHeight + 20;
    }
  }
}

/// Screen type enum
enum ScreenType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

/// Responsive widget that adapts its child based on screen size
class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;

  const ResponsiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final screenType = Responsive.getScreenType(MediaQuery.of(context).size.width);
    
    switch (screenType) {
      case ScreenType.mobile:
        return mobile;
      case ScreenType.tablet:
        return tablet ?? mobile;
      case ScreenType.desktop:
        return desktop ?? tablet ?? mobile;
      case ScreenType.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile;
    }
  }
}

/// Responsive layout builder
class ResponsiveLayoutBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenType screenType) builder;

  const ResponsiveLayoutBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final screenType = Responsive.getScreenType(MediaQuery.of(context).size.width);
    return builder(context, screenType);
  }
}

/// Responsive container that adapts its width based on screen size
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveMaxWidth = maxWidth ?? Responsive.getResponsiveMaxContentWidth(context);
    final responsivePadding = padding ?? Responsive.getResponsivePadding(context);
    final responsiveMargin = margin ?? Responsive.getResponsiveMargin(context);
    final screenType = Responsive.getScreenType(MediaQuery.of(context).size.width);

    // For mobile devices, don't constrain width and don't center
    if (screenType == ScreenType.mobile) {
      return Container(
        padding: responsivePadding,
        child: child,
      );
    }

    // For larger screens, center and constrain width
    return Container(
      margin: responsiveMargin,
      child: Center(
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(maxWidth: responsiveMaxWidth),
          padding: responsivePadding,
          child: child,
        ),
      ),
    );
  }
}

/// Responsive grid view that adapts columns based on screen size
class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final double? childAspectRatio;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;

  const ResponsiveGridView({
    super.key,
    required this.children,
    this.childAspectRatio,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final columns = Responsive.getResponsiveGridColumns(context);
    final spacing = Responsive.getResponsiveSpacing(context, 16);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: childAspectRatio ?? 1.2,
        crossAxisSpacing: crossAxisSpacing ?? spacing,
        mainAxisSpacing: mainAxisSpacing ?? spacing,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// Responsive text that adapts font size based on screen size
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final baseFontSize = style?.fontSize ?? 14;
    final responsiveFontSize = Responsive.getResponsiveFontSize(context, baseFontSize);

    return Text(
      text,
      style: style?.copyWith(fontSize: responsiveFontSize) ?? TextStyle(fontSize: responsiveFontSize),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
