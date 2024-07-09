import 'package:flame_3d/game.dart';

/// Represents an immutable [Vector2].
typedef ImmutableVector2 = ({double x, double y});

extension Vector2Extension on Vector2 {
  /// Returns an immutable representation of the vector.
  ImmutableVector2 get immutable => (x: x, y: y);
}

extension Vector2Math on ImmutableVector2 {
  List<double> get storage => [x, y];

  Vector2 get mutable => Vector2(x, y);
}