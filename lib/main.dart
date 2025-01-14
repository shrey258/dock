import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

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
      onDragStarted: () {},
      onDragEnd: (details) {},
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

/// A dock icon widget that mimics macOS dock behavior.
///
/// This widget provides interactive animations and visual feedback similar to
/// the macOS dock, including hover effects, click animations, and tooltips.
///
/// Example:
/// ```dart
/// DockIcon(
///   icon: Icons.folder_rounded,
///   tooltip: 'Finder',
///   isRecent: true,
///   onTap: () => print('Finder tapped'),
/// )
/// ```
class DockIcon extends StatefulWidget {
  /// The icon to display in the dock.
  final IconData icon;

  /// The tooltip text to show when hovering.
  final String tooltip;

  /// The size of the icon container. Defaults to 50.
  final double size;

  /// Whether to show a recent-use indicator dot. Defaults to false.
  final bool isRecent;

  /// Callback function when the icon is tapped.
  final VoidCallback? onTap;

  // Cache computed values
  final double _iconSize;
  final BoxDecoration _baseDecoration;

  DockIcon({
    super.key,
    required this.icon,
    required this.tooltip,
    this.size = 50,
    this.isRecent = false,
    this.onTap,
  })  : _iconSize = size * 0.6,
        _baseDecoration = BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        );

  @override
  State<DockIcon> createState() => _DockIconState();
}

class _DockIconState extends State<DockIcon>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnimation;

  // Cache commonly used values
  static const _animationDuration = Duration(milliseconds: 300);
  static const _tooltipDelay = Duration(milliseconds: 500);
  static const _bounceScaleFactor = 1.2;
  static const _pressScaleFactor = 0.9;

  // Cache decorations and styles
  static final _tooltipDecoration = BoxDecoration(
    color: Colors.black.withOpacity(0.8),
    borderRadius: BorderRadius.circular(8),
  );

  static const _tooltipTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 12,
  );

  static final _dotDecoration = BoxDecoration(
    color: Colors.white.withOpacity(0.8),
    shape: BoxShape.circle,
  );

  static const _dotMargin = EdgeInsets.symmetric(horizontal: 2);
  static const _dotSize = Size(4, 4);

  late final BoxDecoration _shadowDecoration;
  late final Color _pressedColor;
  late final Color _normalColor;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeStyles();
  }

  void _initializeStyles() {
    _shadowDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 8,
          spreadRadius: 1,
        )
      ],
    );
    _pressedColor = Colors.black.withOpacity(0.3);
    _normalColor = Colors.black.withOpacity(0.2);
  }

  void _initializeAnimations() {
    _bounceController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: _bounceScaleFactor,
    ).animate(
      CurvedAnimation(
        parent: _bounceController,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInBack,
      ),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _bounceController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _bounceController.reverse();
      },
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: SizedBox(
          height: widget.size * 1.2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIconWithTooltip(),
              const SizedBox(height: 4),
              _buildIndicatorDots(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconWithTooltip() {
    return Tooltip(
      message: widget.tooltip,
      decoration: _tooltipDecoration,
      textStyle: _tooltipTextStyle,
      waitDuration: _tooltipDelay,
      child: _buildAnimatedIcon(),
    );
  }

  Widget _buildAnimatedIcon() {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) => Transform.scale(
        scale: _bounceAnimation.value * (_isPressed ? _pressScaleFactor : 1.0),
        child: child,
      ),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: _isHovered && !_isPressed
            ? _shadowDecoration
            : widget._baseDecoration.copyWith(
                color: _isPressed ? _pressedColor : _normalColor,
              ),
        child: Icon(
          widget.icon,
          size: widget._iconSize,
          color: Colors.white.withOpacity(_isPressed ? 0.7 : 1.0),
        ),
      ),
    );
  }

  Widget _buildIndicatorDots() {
    if (!widget.isRecent && !_isHovered) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.isRecent) _buildDot(),
        if (_isHovered) _buildDot(),
      ],
    );
  }

  Widget _buildDot() {
    return SizedBox.fromSize(
      size: _dotSize,
      child: Container(
        margin: _dotMargin,
        decoration: _dotDecoration,
      ),
    );
  }
}

class MacOSDock extends StatelessWidget {
  const MacOSDock({Key? key}) : super(key: key);

  void _handleAppTap(BuildContext context, String appName) {
    // Simulate app launch with a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening $appName...'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black.withOpacity(0.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: DockContainer(
            children: [
              DockIcon(
                icon: Icons.folder_rounded,
                tooltip: 'Finder',
                isRecent: true,
                onTap: () => _handleAppTap(context, 'Finder'),
              ),
              DockIcon(
                icon: Icons.web_rounded,
                tooltip: 'Safari',
                onTap: () => _handleAppTap(context, 'Safari'),
              ),
              DockIcon(
                icon: Icons.mail_rounded,
                tooltip: 'Mail',
                isRecent: true,
                onTap: () => _handleAppTap(context, 'Mail'),
              ),
              DockIcon(
                icon: Icons.calendar_month_rounded,
                tooltip: 'Calendar',
                onTap: () => _handleAppTap(context, 'Calendar'),
              ),
              DockIcon(
                icon: Icons.photo_library_rounded,
                tooltip: 'Photos',
                onTap: () => _handleAppTap(context, 'Photos'),
              ),
              DockIcon(
                icon: Icons.message_rounded,
                tooltip: 'Messages',
                onTap: () => _handleAppTap(context, 'Messages'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DockContainer extends StatefulWidget {
  final List<DockIcon> children;

  const DockContainer({
    Key? key,
    required this.children,
  }) : super(key: key);

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
  late List<DockIcon> _items;
  int? _dragIndex;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: animationDuration,
    );
    _items = List.from(widget.children);
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
      final DockIcon item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
    });
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
                    final DockIcon item = _items.removeAt(oldIndex);
                    _items.insert(newIndex, item);
                  });
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

  Widget _buildDockIcon(DockIcon item, double dockHeight, double scale,
      BoxConstraints constraints, int index) {
    return GestureDetector(
      onTap: () {},
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
          child: item,
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
    Key? key,
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
  // Animation controller for smooth transitions
  late AnimationController _animationController;

  // Track dragging state
  int? _currentDraggedIndex;
  int? _currentDropTargetIndex;
  bool _isCurrentlyDragging = false;
  Offset? _currentDragOffset;

  // UI Constants
  static const double _iconSize = 80.0;
  static const double _targetScaleFactor = 1.2;
  static const Duration _animationDuration = Duration(milliseconds: 200);
  static const Curve _animationCurve = Curves.easeOutQuart;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Calculate how much each icon should move to make space for dragged item
  double _getOffsetForIndex(int index) {
    if (!_isCurrentlyDragging ||
        _currentDraggedIndex == null ||
        _currentDropTargetIndex == null) {
      return 0.0;
    }

    if (_currentDraggedIndex! < _currentDropTargetIndex!) {
      // Moving right: shift items left to make space
      if (index <= _currentDraggedIndex!) return 0.0;
      if (index > _currentDropTargetIndex!) return 0.0;
      return -_iconSize;
    } else {
      // Moving left: shift items right to make space
      if (index >= _currentDraggedIndex!) return 0.0;
      if (index < _currentDropTargetIndex!) return 0.0;
      return _iconSize;
    }
  }

  /// Update the target index based on drag position
  void _updateDropTarget(Offset globalPosition, BuildContext context) {
    final RenderBox containerBox = context.findRenderObject() as RenderBox;
    final localPosition = containerBox.globalToLocal(globalPosition);

    for (int i = 0; i < widget.children.length; i++) {
      final itemStartX = i * _iconSize;
      final itemEndX = itemStartX + _iconSize;

      if (localPosition.dx >= itemStartX && localPosition.dx < itemEndX) {
        if (_currentDropTargetIndex != i) {
          setState(() => _currentDropTargetIndex = i);
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

  /// Build a draggable dock icon with animations and feedback
  Widget _buildDraggableItem(int index) {
    return Draggable<int>(
      data: index,
      dragAnchorStrategy: (draggable, context, position) {
        // Center the drag feedback under the pointer
        return const Offset(_iconSize / 2, _iconSize / 2);
      },
      // Visual feedback while dragging
      feedback: SizedBox(
        width: _iconSize,
        height: _iconSize,
        child: widget.proxyDecorator?.call(
              widget.children[index],
              index,
              _animationController,
            ) ??
            widget.children[index],
      ),
      childWhenDragging: SizedBox(width: _iconSize, height: _iconSize),
      onDragStarted: () {
        setState(() {
          _currentDraggedIndex = index;
          _currentDropTargetIndex = index;
          _isCurrentlyDragging = true;
        });
        _animationController.forward();
      },
      onDragUpdate: (details) =>
          _updateDropTarget(details.globalPosition, context),
      onDragEnd: (_) {
        if (_currentDraggedIndex != null &&
            _currentDropTargetIndex != null &&
            _currentDraggedIndex != _currentDropTargetIndex) {
          widget.onReorder(_currentDraggedIndex!, _currentDropTargetIndex!);
        }
        setState(() {
          _currentDraggedIndex = null;
          _currentDropTargetIndex = null;
          _isCurrentlyDragging = false;
        });
        _animationController.reverse();
      },
      child: AnimatedContainer(
        duration: _animationDuration,
        curve: _animationCurve,
        transform: Matrix4.identity()..translate(_getOffsetForIndex(index)),
        child: DragTarget<int>(
          onWillAccept: (sourceIndex) =>
              sourceIndex != null && sourceIndex != index,
          onAccept: (sourceIndex) {
            widget.onReorder(sourceIndex, index);
          },
          builder: (context, candidateData, rejectedData) {
            final isTargetLocation = _currentDropTargetIndex == index &&
                _currentDraggedIndex != index;
            return AnimatedScale(
              scale: isTargetLocation ? _targetScaleFactor : 1.0,
              duration: _animationDuration,
              curve: _animationCurve,
              child: widget.children[index],
            );
          },
        ),
      ),
    );
  }
}
