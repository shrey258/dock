import 'dart:ui';

import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (icon) {
              return Container(
                width: 56,
                height: 56,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.primaries[icon.hashCode % Colors.primaries.length]
                          .withOpacity(0.8),
                      Colors.primaries[icon.hashCode % Colors.primaries.length],
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Dock of the reorderable [items].
class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
    this.itemSize = 56.0,
    this.maxScale = 1.5,
  });

  /// Initial [T] items to put in this [Dock].
  final List<T> items;

  /// Builder building the provided [T] item.
  final Widget Function(T) builder;

  /// Size of each item in the dock.
  final double itemSize;

  /// Maximum scale of the item when dragging.
  final double maxScale;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T> extends State<Dock<T>> with TickerProviderStateMixin {
  /// [T] items being manipulated.
  late final List<T> _items = widget.items.toList();

  /// Position of the drag.
  double? _dragPosition;

  /// Index of the item being dragged.
  int? _draggedIndex;

  /// Keys for the items in the dock.
  late List<GlobalKey> _keys;

  @override
  void initState() {
    super.initState();
    _keys = List.generate(
      _items.length,
      (index) => GlobalKey(debugLabel: 'dock_item_$index'),
    );
  }

  /// Calculate the scale of the item based on the distance from the drag position.
  double _getScale(double distance, double position) {
    final maxDistance = widget.itemSize * 1.5;
    if (distance > maxDistance) return 1.0;

    final scale = 1.0 + (widget.maxScale - 1.0) * (1 - distance / maxDistance);
    return scale;
  }

  /// Update the drag position.
  void _updateDragPosition(Offset globalPosition) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(globalPosition);
    setState(() {
      _dragPosition = localPosition.dx;
    });
  }

  /// Handle drag update.
  void _onDragUpdate(DragUpdateDetails details, int index) {
    _updateDragPosition(details.globalPosition);
    final draggedItemNewIndex = _getTargetIndex(details.globalPosition);

    if (draggedItemNewIndex != null &&
        draggedItemNewIndex != _draggedIndex &&
        draggedItemNewIndex >= 0 &&
        draggedItemNewIndex < _items.length) {
      setState(() {
        final item = _items.removeAt(_draggedIndex!);
        _items.insert(draggedItemNewIndex, item);

        final key = _keys.removeAt(_draggedIndex!);
        _keys.insert(draggedItemNewIndex, key);

        _draggedIndex = draggedItemNewIndex;
      });
    }
  }

  /// Get the target index of the drag.
  int? _getTargetIndex(Offset globalPosition) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(globalPosition);
    final dx = localPosition.dx;

    return (dx ~/ (widget.itemSize + 24)).clamp(0, _items.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.1),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_items.length, (index) {
                final item = _items[index];

                return MouseRegion(
                  onHover: (event) {
                    _updateDragPosition(event.position);
                    setState(() {});
                  },
                  onExit: (event) {
                    setState(() {
                      _dragPosition = null;
                    });
                  },
                  child: Draggable<int>(
                    data: index,
                    feedback: Material(
                      color: Colors.transparent,
                      child: AnimatedScale(
                        scale: widget.maxScale,
                        duration: const Duration(milliseconds: 150),
                        child: widget.builder(item),
                      ),
                    ),
                    childWhenDragging: const SizedBox(),
                    onDragStarted: () {
                      setState(() {
                        _draggedIndex = index;
                        _dragPosition = null;
                      });
                    },
                    onDragEnd: (details) {
                      setState(() {
                        _draggedIndex = null;
                        _dragPosition = null;
                      });
                    },
                    onDragUpdate: (details) => _onDragUpdate(details, index),
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 150),
                      scale: _dragPosition != null
                          ? _getScale(
                              (_dragPosition! -
                                      (index * (widget.itemSize + 24) +
                                          widget.itemSize / 2))
                                  .abs(),
                              _dragPosition!,
                            )
                          : 1.0,
                      child: widget.builder(item),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
