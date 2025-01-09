import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const DockExample(),
    );
  }
}

class DockExample extends StatelessWidget {
  const DockExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?auto=format&fit=crop&q=80',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            const Spacer(),
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: const MacOSDock(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DockItem {
  final String icon;
  final String tooltip;
  final VoidCallback? onTap;

  const DockItem({
    required this.icon,
    required this.tooltip,
    this.onTap,
  });
}

class MacOSDock extends StatelessWidget {
  const MacOSDock({super.key});

  @override
  Widget build(BuildContext context) {
    return const DockContainer(
      items: [
        DockItem(
          icon: 'https://api.iconify.design/mdi/folder.svg',
          tooltip: 'Finder',
        ),
        DockItem(
          icon: 'https://api.iconify.design/mdi/google-chrome.svg',
          tooltip: 'Chrome',
        ),
        DockItem(
          icon: 'https://api.iconify.design/mdi/compass.svg',
          tooltip: 'Safari',
        ),
        DockItem(
          icon: 'https://api.iconify.design/mdi/gmail.svg',
          tooltip: 'Mail',
        ),
        DockItem(
          icon: 'https://api.iconify.design/mdi/calendar.svg',
          tooltip: 'Calendar',
        ),
        DockItem(
          icon: 'https://api.iconify.design/mdi/image.svg',
          tooltip: 'Photos',
        ),
        DockItem(
          icon: 'https://api.iconify.design/mdi/message.svg',
          tooltip: 'Messages',
        ),
        DockItem(
          icon: 'https://api.iconify.design/mdi/signal.svg',
          tooltip: 'Signal',
        ),
        DockItem(
          icon: 'https://api.iconify.design/mdi/spotify.svg',
          tooltip: 'Spotify',
        ),
        DockItem(
          icon:
              'https://api.iconify.design/mdi/microsoft-visual-studio-code.svg',
          tooltip: 'VS Code',
        ),
        DockItem(
          icon: 'https://api.iconify.design/mdi/console.svg',
          tooltip: 'Terminal',
        ),
        DockItem(
          icon: 'https://api.iconify.design/mdi/delete.svg',
          tooltip: 'Trash',
        ),
      ],
    );
  }
}

class DockContainer extends StatefulWidget {
  final List<DockItem> items;

  const DockContainer({
    super.key,
    required this.items,
  });

  @override
  State<DockContainer> createState() => _DockContainerState();
}

class _DockContainerState extends State<DockContainer>
    with SingleTickerProviderStateMixin {
  static const double minWidth = 50;
  static const double maxWidth = 85;
  static const double heightFractionOfScreen = 0.075;
  static const double dockPadding = 8;
  static const double iconPadding = 4;
  static const double maxZoom = 2.0;
  static const Duration animationDuration = Duration(milliseconds: 150);
  static const Curve animationCurve = Curves.easeOutQuart;

  late final AnimationController _controller;
  Offset? _mousePosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: animationDuration,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _calculateScale(double distance, double maxDistance) {
    if (distance > maxDistance) return 1.0;

    final double normalizedDistance = distance / maxDistance;
    final double scale = 1 - math.pow(normalizedDistance, 2) as double;

    return 1.0 + (maxZoom - 1.0) * scale;
  }

  double _calculateWidth(int index, BoxConstraints constraints) {
    if (_mousePosition == null) return minWidth;

    final itemCenter = index * (minWidth + iconPadding * 2) + minWidth / 2;
    final distance = (_mousePosition!.dx - itemCenter).abs();
    final maxDistance = minWidth * 2;

    final scale = _calculateScale(distance, maxDistance);
    return minWidth * scale;
  }

  double _calculateOffset(int index, double scale) {
    final normalizedScale = (scale - 1.0) / (maxZoom - 1.0);
    final lift = 30 * math.pow(normalizedScale, 2);
    return -lift as double;
  }

  List<double> _calculateNeighborScales(int index) {
    if (_mousePosition == null) return List.filled(widget.items.length, 1.0);

    final scales = List<double>.filled(widget.items.length, 1.0);
    final itemCenter = index * (minWidth + iconPadding * 2) + minWidth / 2;
    final mouseDistance = (_mousePosition!.dx - itemCenter).abs();
    final maxDistance = minWidth * 2;

    scales[index] = _calculateScale(mouseDistance, maxDistance);

    if (index > 0) {
      scales[index - 1] =
          _calculateScale(mouseDistance + minWidth, maxDistance) * 0.9;
    }
    if (index < widget.items.length - 1) {
      scales[index + 1] =
          _calculateScale(mouseDistance + minWidth, maxDistance) * 0.9;
    }

    return scales;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final dockHeight = screenSize.height * heightFractionOfScreen;

    return MouseRegion(
      onHover: (event) => setState(() => _mousePosition = event.localPosition),
      onExit: (_) => setState(() => _mousePosition = null),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: dockPadding,
          vertical: dockPadding,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 1,
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                widget.items.length,
                (index) {
                  final scales = _calculateNeighborScales(index);
                  final scale = scales[index];

                  return GestureDetector(
                    onTap: widget.items[index].onTap,
                    child: Transform.translate(
                      offset: Offset(0, _calculateOffset(index, scale)),
                      child: AnimatedContainer(
                        duration: animationDuration,
                        curve: animationCurve,
                        height: dockHeight,
                        width: _calculateWidth(index, constraints),
                        margin: const EdgeInsets.symmetric(
                          horizontal: iconPadding,
                        ),
                        child: Tooltip(
                          message: widget.items[index].tooltip,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: const TextStyle(color: Colors.white),
                          child: SvgPicture.network(
                            widget.items[index].icon,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                            placeholderBuilder: (BuildContext context) =>
                                Container(
                              color: Colors.white.withOpacity(0.3),
                              child: const Icon(
                                Icons.apps,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
