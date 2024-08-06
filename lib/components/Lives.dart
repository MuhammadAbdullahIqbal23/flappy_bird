import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flappy_bird/game/FlappyBirdGame.dart';
import 'package:flappy_bird/game/assets.dart';

class Lives extends SpriteComponent with HasGameRef<FlappyBirdGame> {
  Lives();
  @override
  Future<void> onLoad() async {
    final life = await Flame.images.load(Assets.life);

    // Set size to 1/10 of the game screen
    size = gameRef.size / 10;

    // Set position to bottom left corner
    position = Vector2(
        0, // X position (left side)
        gameRef.size.y -
            size.y // Y position (bottom of the screen minus the height of the life icon)
        );

    sprite = Sprite(life);
  }
}
