import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      home: const MacOSDesktop(),
    );
  }
}

class MacOSDesktop extends StatelessWidget {
  const MacOSDesktop({super.key});

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
        child: Stack(
          children: [
            // Main draggable content area
            const Positioned.fill(
              top: 24, // Below menu bar
              bottom: 100, // Above dock
              child: DraggableDesktopArea(),
            ),
            // Menu Bar with improved blur and transparency
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
                    height: 24,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.apple, size: 14, color: Colors.white),
                        const SizedBox(width: 12),
                        Text(
                          'Finder',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Improved Dock
            Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              child: Center(
                child: const MacOSDock(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DraggableDesktopArea extends StatefulWidget {
  const DraggableDesktopArea({super.key});

  @override
  State<DraggableDesktopArea> createState() => _DraggableDesktopAreaState();
}

class _DraggableDesktopAreaState extends State<DraggableDesktopArea> {
  final List<DesktopItem> _items = [
    DesktopItem(name: 'Documents', icon: Icons.folder),
    DesktopItem(name: 'Downloads', icon: Icons.download_rounded),
    DesktopItem(name: 'Applications', icon: Icons.apps),
    DesktopItem(name: 'Desktop', icon: Icons.desktop_windows),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 24,
            runSpacing: 24,
            children: _items.map((item) => _buildDraggableItem(item)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDraggableItem(DesktopItem item) {
    return Draggable<DesktopItem>(
      data: item,
      dragAnchorStrategy: (draggable, context, position) {
        return Offset(40, 40); // Center of the icon
      },
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.8,
          child: Container(
            width: 80,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    item.icon,
                    size: 32,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildDesktopItem(item),
      ),
      onDragStarted: () {
        HapticFeedback.mediumImpact();
      },
      onDragEnd: (details) {
        HapticFeedback.lightImpact();
      },
      child: _buildDesktopItem(item),
    );
  }

  Widget _buildDesktopItem(DesktopItem item) {
    return Container(
      width: 80,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item.icon,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.name,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class DesktopItem {
  final String name;
  final IconData icon;

  DesktopItem({
    required this.name,
    required this.icon,
  });
}

class DockItem {
  final IconData icon;
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
    return DragTarget<DesktopItem>(
      onWillAccept: (_) {
        HapticFeedback.selectionClick();
        return true;
      },
      onAcceptWithDetails: (details) {
        final item = details.data;
        HapticFeedback.mediumImpact();

        // Show a bouncing animation on the dock
        final RenderBox box = context.findRenderObject() as RenderBox;
        final position = box.localToGlobal(Offset.zero);
        final dockCenter = position.dy + box.size.height / 2;

        // Calculate bounce based on drop position
        final dropDelta = (details.offset.dy - dockCenter).abs();
        final bounceScale = math.max(0, 1 - dropDelta / 100);

        if (bounceScale > 0.3) {
          // Show success animation and feedback
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(item.icon, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text('Opening ${item.name}...'),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.black.withOpacity(0.8),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
      onLeave: (_) {
        HapticFeedback.lightImpact();
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return AnimatedScale(
          scale: isHovering ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: DockContainer(
            items: const [
              DockItem(
                icon: Icons.folder_rounded,
                tooltip: 'Finder',
              ),
              DockItem(
                icon: Icons.public_rounded,
                tooltip: 'Chrome',
              ),
              DockItem(
                icon: Icons.compass_calibration_rounded,
                tooltip: 'Safari',
              ),
              DockItem(
                icon: Icons.mail_rounded,
                tooltip: 'Mail',
              ),
              DockItem(
                icon: Icons.calendar_month_rounded,
                tooltip: 'Calendar',
              ),
              DockItem(
                icon: Icons.photo_library_rounded,
                tooltip: 'Photos',
              ),
              DockItem(
                icon: Icons.message_rounded,
                tooltip: 'Messages',
              ),
            ],
          ),
        );
      },
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
  late List<DockItem> _items;
  int? _dragIndex;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: animationDuration,
    );
    _items = List.from(widget.items);
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
    if (_mousePosition == null) return List.filled(_items.length, 1.0);

    final scales = List<double>.filled(_items.length, 1.0);
    final itemCenter = index * (minWidth + iconPadding * 2) + minWidth / 2;
    final mouseDistance = (_mousePosition!.dx - itemCenter).abs();
    final maxDistance = minWidth * 2;

    scales[index] = _calculateScale(mouseDistance, maxDistance);

    if (index > 0) {
      scales[index - 1] =
          _calculateScale(mouseDistance + minWidth, maxDistance) * 0.9;
    }
    if (index < _items.length - 1) {
      scales[index + 1] =
          _calculateScale(mouseDistance + minWidth, maxDistance) * 0.9;
    }

    return scales;
  }

  void _handleReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final DockItem item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
    });
    HapticFeedback.mediumImpact();
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
            return SizedBox(
              height: dockHeight + dockPadding * 2,
              child: ReorderableRow(
                mainAxisSize: MainAxisSize.min,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final DockItem item = _items.removeAt(oldIndex);
                    _items.insert(newIndex, item);
                  });
                  HapticFeedback.mediumImpact();
                },
                proxyDecorator: (child, index, animation) {
                  return AnimatedBuilder(
                    animation: animation,
                    builder: (context, child) {
                      final double scale = lerpDouble(1, 1.1, animation.value)!;
                      return Transform.scale(
                        scale: scale,
                        child: Material(
                          color: Colors.transparent,
                          child: child,
                        ),
                      );
                    },
                    child: child,
                  );
                },
                children: List.generate(
                  _items.length,
                  (index) {
                    final scales = _calculateNeighborScales(index);
                    final scale = scales[index];
                    final item = _items[index];

                    return KeyedSubtree(
                      key: ValueKey(item),
                      child: _buildDockIcon(
                          item, dockHeight, scale, constraints, index),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDockIcon(DockItem item, double dockHeight, double scale,
      BoxConstraints constraints, int index) {
    return GestureDetector(
      onTap: item.onTap,
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
            message: item.tooltip,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(color: Colors.white),
            child: Icon(
              item.icon,
              color: Colors.white.withOpacity(0.95),
              size: dockHeight * 0.5 * scale,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReorderableRow extends StatefulWidget {
  final List<Widget> children;
  final void Function(int oldIndex, int newIndex) onReorder;
  final Widget Function(Widget child, int index, Animation<double> animation)?
      proxyDecorator;
  final MainAxisSize mainAxisSize;

  const ReorderableRow({
    super.key,
    required this.children,
    required this.onReorder,
    this.proxyDecorator,
    this.mainAxisSize = MainAxisSize.max,
  });

  @override
  State<ReorderableRow> createState() => _ReorderableRowState();
}

class _ReorderableRowState extends State<ReorderableRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int? _dragIndex;
  int? _targetIndex;
  bool _isDragging = false;
  Offset? _dragOffset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _getOffsetForIndex(int index) {
    if (!_isDragging || _dragIndex == null || _targetIndex == null) {
      return 0.0;
    }

    final draggedItemWidth = 80.0; // Approximate width of dock item
    
    if (_dragIndex! < _targetIndex!) {
      // Moving right
      if (index <= _dragIndex!) return 0.0;
      if (index > _targetIndex!) return 0.0;
      return -draggedItemWidth;
    } else {
      // Moving left
      if (index >= _dragIndex!) return 0.0;
      if (index < _targetIndex!) return 0.0;
      return draggedItemWidth;
    }
  }

  void _updateTargetIndex(Offset globalPosition, BuildContext context) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(globalPosition);
    
    for (int i = 0; i < widget.children.length; i++) {
      final itemWidth = 80.0; // Approximate width of dock item
      final itemX = i * itemWidth;
      
      if (localPosition.dx >= itemX && localPosition.dx < itemX + itemWidth) {
        if (_targetIndex != i) {
          setState(() => _targetIndex = i);
        }
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: widget.mainAxisSize,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.children.length,
        (index) => _buildDraggableItem(index),
      ),
    );
  }

  Widget _buildDraggableItem(int index) {
    return Draggable<int>(
      data: index,
      dragAnchorStrategy: (draggable, context, position) {
        return const Offset(40, 40);
      },
      feedback: SizedBox(
        width: 80,
        height: 80,
        child: widget.proxyDecorator?.call(
              widget.children[index],
              index,
              _controller,
            ) ??
            widget.children[index],
      ),
      childWhenDragging: const SizedBox(width: 80, height: 80),
      onDragStarted: () {
        setState(() {
          _dragIndex = index;
          _targetIndex = index;
          _isDragging = true;
        });
        _controller.forward();
        HapticFeedback.mediumImpact();
      },
      onDragUpdate: (details) {
        _updateTargetIndex(details.globalPosition, context);
      },
      onDragEnd: (_) {
        if (_dragIndex != null && _targetIndex != null && _dragIndex != _targetIndex) {
          widget.onReorder(_dragIndex!, _targetIndex!);
        }
        setState(() {
          _dragIndex = null;
          _targetIndex = null;
          _isDragging = false;
        });
        _controller.reverse();
        HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..translate(_getOffsetForIndex(index)),
        child: DragTarget<int>(
          onWillAccept: (sourceIndex) =>
              sourceIndex != null && sourceIndex != index,
          onAccept: (sourceIndex) {
            widget.onReorder(sourceIndex, index);
            HapticFeedback.mediumImpact();
          },
          builder: (context, candidateData, rejectedData) {
            final isTarget = _targetIndex == index && _dragIndex != index;
            return AnimatedScale(
              scale: isTarget ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: widget.children[index],
            );
          },
        ),
      ),
    );
  }
}
