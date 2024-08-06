import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flappy_bird/components/bird.dart';
import 'package:flappy_bird/game/FlappyBirdGame.dart';
import 'package:flappy_bird/game/assets.dart';
import 'package:flappy_bird/game/configuration.dart'; // Add this import

class PowerUp extends SpriteComponent
    with HasGameRef<FlappyBirdGame>, CollisionCallbacks {
  PowerUp({required Vector2 position}) : super(position: position);

  @override
  Future<void> onLoad() async {
    final powerUpSprite = await gameRef
        .loadSprite(Assets.powerUp); // You'll need to add this asset
    sprite = powerUpSprite;
    size = Vector2(30, 30); // Adjust size as needed
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= Config.gameSpeed * dt; // Use Config.gameSpeed directly

    if (position.x < -size.x) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Bird) {
      other.activatePowerUp();
      removeFromParent();
    }
  }
}
