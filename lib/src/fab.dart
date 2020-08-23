import 'package:flutter/material.dart';

const double _kDefaultElevation = 6;
const double _kDefaultFocusElevation = 8;
const double _kDefaultHoverElevation = 10;
const double _kDefaultHighlightElevation = 12;

class ExtendableFab extends StatefulWidget {
  final Widget icon;
  final Widget label;
  final Duration duration;
  final VoidCallback onTap;
  final VoidCallback onLongTap;
  final double elevation;
  final double focusElevation;
  final double hoverElevation;
  final double highlightElevation;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color splashColor;
  final bool expanded;
  final bool mini;

  ExtendableFab({
    @required this.icon,
    this.label,
    this.duration = const Duration(milliseconds: 250),
    this.onTap,
    this.onLongTap,
    this.elevation = _kDefaultElevation,
    this.focusElevation = _kDefaultFocusElevation,
    this.hoverElevation = _kDefaultHoverElevation,
    this.highlightElevation = _kDefaultHighlightElevation,
    this.backgroundColor,
    this.foregroundColor,
    this.splashColor,
    this.expanded = false,
    this.mini,
  });

  @override
  _ExtendableFabState createState() => _ExtendableFabState();
}

class _ExtendableFabState extends State<ExtendableFab>
    with TickerProviderStateMixin {
  bool _expanded;
  bool _mini;
  bool _hovered = false;
  bool _focused = false;
  bool _highlighted = false;
  double _elevation;

  @override
  void initState() {
    _updateBasedOnLocation(
      Scaffold.of(context).widget.floatingActionButtonLocation,
    );
    super.initState();
  }

  @override
  void didUpdateWidget(ExtendableFab oldWidget) {
    _updateBasedOnLocation(
      Scaffold.of(context).widget.floatingActionButtonLocation,
    );
    if (widget.expanded != oldWidget.expanded) {
      _expanded = widget.expanded ?? _expanded;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final floatingActionButtonTheme =
        Theme.of(context).floatingActionButtonTheme;

    _expanded ??= widget.expanded ?? false;
    _elevation ??= widget.elevation;
    final Color foregroundColor = widget.foregroundColor ??
        floatingActionButtonTheme.foregroundColor ??
        theme.colorScheme.onSecondary;
    final Color splashColor = widget.backgroundColor ??
        floatingActionButtonTheme.splashColor ??
        theme.splashColor;

    if (_highlighted) {
      _elevation = widget.highlightElevation;
    } else if (_hovered) {
      _elevation = widget.hoverElevation;
    } else if (_focused) {
      _elevation = widget.focusElevation;
    } else {
      _elevation = widget.elevation;
    }

    return AnimatedPadding(
      duration: widget.duration,
      curve: Curves.fastOutSlowIn,
      padding: EdgeInsets.all(_mini ? 4 : 0),
      child: Material(
        shape: StadiumBorder(),
        color: widget.backgroundColor ??
            floatingActionButtonTheme.backgroundColor ??
            theme.colorScheme.secondary,
        clipBehavior: Clip.antiAlias,
        elevation: _elevation,
        child: InkWell(
          onHover: (value) => setState(() {
            _hovered = value;
            if (widget.expanded == null || !widget.expanded) _expanded = value;
          }),
          onLongPress: widget.onLongTap,
          onFocusChange: (value) => setState(() {
            _focused = value;
            if (widget.expanded == null || !widget.expanded) _expanded = value;
          }),
          onTap: widget.onTap,
          onHighlightChanged: (value) => setState(() {
            _highlighted = value;
          }),
          splashColor: splashColor,
          child: AnimatedContainer(
            duration: widget.duration,
            curve: Curves.fastOutSlowIn,
            height: _mini ? 40 : 48,
            padding: EdgeInsets.symmetric(
              horizontal: _mini ? _expanded ? 12 : 8 : _expanded ? 16 : 12,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconTheme.merge(
                  data: IconThemeData(
                    color: foregroundColor,
                  ),
                  child: widget.icon,
                ),
                DefaultTextStyle(
                  style: theme.textTheme.button.copyWith(
                    color: foregroundColor,
                    letterSpacing: 1.2,
                  ),
                  child: Visibility(
                    visible: widget.label != null,
                    child: AnimatedSize(
                      duration: widget.duration,
                      curve: Curves.fastOutSlowIn,
                      vsync: this,
                      child: AnimatedOpacity(
                        opacity: _expanded ? 1 : 0,
                        curve: Curves.fastOutSlowIn,
                        duration: widget.duration,
                        child: _expanded
                            ? Padding(
                                padding: EdgeInsets.only(
                                  left: 12,
                                  right: _mini ? 8 : 4,
                                ),
                                child: widget.label,
                              )
                            : Container(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updateBasedOnLocation(FloatingActionButtonLocation location) {
    _mini = widget.mini ?? location is FabMiniOffsetAdjustment;
  }
}

extension IterableBounds on Iterable {
  bool withinBounds(int lowerBound, int upperBound) {
    if (lowerBound.isNegative || upperBound.isNegative)
      throw ArgumentError("Can't have negative bounds");

    return length >= lowerBound && length <= upperBound;
  }
}
