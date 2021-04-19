import 'dart:ui';

import '../../components.dart';
import '../extensions/vector2.dart';
import 'shape_intersections.dart' as intersection_system;

/// A shape can represent any geometrical shape with optionally a size, position
/// and angle. It can also have an anchor if it shouldn't be rotated around its
/// center.
/// A point can be determined to be within of outside of a shape.
abstract class Shape {
  /// The position of your shape, it is up to you how you treat this
  Vector2 position;

  /// The position of your shape in relation to its size
  Vector2 relativePosition = Vector2.zero();

  /// The size is the bounding box of the [Shape]
  Vector2? size;

  /// The angle of the shape from its initial definition
  double angle;

  /// The angle of the parent that has to be taken into consideration for some
  /// applications of [Shape], for example [HitboxShape]
  double parentAngle;

  /// The shape's absolute center with rotation taken into account
  Vector2 get shapeCenter {
    if (angle == 0 && relativePosition.isZero() && _anchorPosition == null) {
      return position;
    } else {
      final center = position + ((size! / 2)..multiply(relativePosition));
      return center..rotate(parentAngle + angle, center: anchorPosition);
    }
  }

  /// The position that the shape rotates around
  Vector2? _anchorPosition;
  Vector2 _unrotatedCenter() => position + (size! / 2)
    ..multiply(relativePosition);
  Vector2 get anchorPosition => _anchorPosition ?? _unrotatedCenter();
  set anchorPosition(Vector2 position) => _anchorPosition = position;

  Shape({
    Vector2? position,
    this.size,
    this.angle = 0,
    this.parentAngle = 0,
  }) : position = position ?? Vector2.zero();

  /// Whether the point [p] is within the shapes boundaries or not
  bool containsPoint(Vector2 p);

  void render(Canvas c, Paint paint);

  /// Where this Shape has intersection points with another shape
  Set<Vector2> intersections(Shape other) {
    return intersection_system.intersections(this, other);
  }
}

mixin HitboxShape on Shape {
  late PositionComponent component;

  @override
  Vector2 get anchorPosition => component.absolutePosition;

  @override
  Vector2 get size => component.size;

  @override
  double get parentAngle => component.angle;

  /// The shape's absolute center
  @override
  Vector2 get shapeCenter {
    if (position.isZero() && relativePosition.isZero()) {
      return component.absoluteCenter;
    } else {
      final rotatedCenter = (position +
          ((size / 2)..multiply(relativePosition)))
        ..rotate(parentAngle, center: anchorPosition);
      return component.absoluteCenter + rotatedCenter;
    }
  }

  /// Assign your own [CollisionCallback] if you want a callback when this
  /// shape collides with another [HitboxShape]
  CollisionCallback onCollision = emptyCollisionCallback;
}

typedef CollisionCallback = void Function(
  Set<Vector2> intersectionPoints,
  HitboxShape other,
);

void emptyCollisionCallback(Set<Vector2> _, HitboxShape __) {}

/// Used for caching calculated shapes, the cache is determined to be valid by
/// comparing a list of values that can be of any type and is compared to the
/// values that was last used when the cache was updated.
class ShapeCache<T> {
  T? value;

  List<dynamic> _lastValidCacheValues = <dynamic>[];

  ShapeCache();

  bool isCacheValid<F>(List<F> validCacheValues) {
    if (value == null) {
      return false;
    }
    for (var i = 0; i < _lastValidCacheValues.length; ++i) {
      if (_lastValidCacheValues[i] != validCacheValues[i]) {
        return false;
      }
    }
    return true;
  }

  T updateCache<F>(T value, List<F> validCacheValues) {
    this.value = value;
    _lastValidCacheValues = validCacheValues;
    return value;
  }
}
