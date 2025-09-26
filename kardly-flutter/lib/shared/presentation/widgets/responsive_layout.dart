import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= 768) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

class ResponsiveBreakpoints {
  static const double mobile = 768;
  static const double tablet = 1200;
  
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < tablet;
  }
  
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tablet;
  }
}

class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;

  const ResponsiveGridView({
    super.key,
    required this.children,
    this.spacing = 12,
    this.runSpacing = 12,
    this.mobileColumns = 2,
    this.tabletColumns = 3,
    this.desktopColumns = 4,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns;
        if (constraints.maxWidth >= ResponsiveBreakpoints.tablet) {
          columns = desktopColumns;
        } else if (constraints.maxWidth >= ResponsiveBreakpoints.mobile) {
          columns = tabletColumns;
        } else {
          columns = mobileColumns;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: runSpacing,
            childAspectRatio: 0.75, // Adjust based on your content
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}

class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? mobile;
  final EdgeInsetsGeometry? tablet;
  final EdgeInsetsGeometry? desktop;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    EdgeInsetsGeometry padding;
    
    if (ResponsiveBreakpoints.isDesktop(context)) {
      padding = desktop ?? tablet ?? mobile ?? const EdgeInsets.all(24);
    } else if (ResponsiveBreakpoints.isTablet(context)) {
      padding = tablet ?? mobile ?? const EdgeInsets.all(20);
    } else {
      padding = mobile ?? const EdgeInsets.all(16);
    }

    return Padding(
      padding: padding,
      child: child,
    );
  }
}

class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? mobileStyle;
  final TextStyle? tabletStyle;
  final TextStyle? desktopStyle;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    super.key,
    this.mobileStyle,
    this.tabletStyle,
    this.desktopStyle,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle? style;
    
    if (ResponsiveBreakpoints.isDesktop(context)) {
      style = desktopStyle ?? tabletStyle ?? mobileStyle;
    } else if (ResponsiveBreakpoints.isTablet(context)) {
      style = tabletStyle ?? mobileStyle;
    } else {
      style = mobileStyle;
    }

    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? mobileWidth;
  final double? tabletWidth;
  final double? desktopWidth;
  final double? mobileHeight;
  final double? tabletHeight;
  final double? desktopHeight;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Decoration? decoration;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.mobileWidth,
    this.tabletWidth,
    this.desktopWidth,
    this.mobileHeight,
    this.tabletHeight,
    this.desktopHeight,
    this.padding,
    this.margin,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    double? width;
    double? height;
    
    if (ResponsiveBreakpoints.isDesktop(context)) {
      width = desktopWidth ?? tabletWidth ?? mobileWidth;
      height = desktopHeight ?? tabletHeight ?? mobileHeight;
    } else if (ResponsiveBreakpoints.isTablet(context)) {
      width = tabletWidth ?? mobileWidth;
      height = tabletHeight ?? mobileHeight;
    } else {
      width = mobileWidth;
      height = mobileHeight;
    }

    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: decoration,
      child: child,
    );
  }
}

extension ResponsiveExtensions on BuildContext {
  bool get isMobile => ResponsiveBreakpoints.isMobile(this);
  bool get isTablet => ResponsiveBreakpoints.isTablet(this);
  bool get isDesktop => ResponsiveBreakpoints.isDesktop(this);
  
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  
  EdgeInsets get responsivePadding {
    if (isDesktop) return const EdgeInsets.all(24);
    if (isTablet) return const EdgeInsets.all(20);
    return const EdgeInsets.all(16);
  }
  
  int get responsiveColumns {
    if (isDesktop) return 4;
    if (isTablet) return 3;
    return 2;
  }
}
