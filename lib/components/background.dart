import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flappy_bird/game/FlappyBirdGame.dart';
import 'package:flappy_bird/game/assets.dart';

class Background extends SpriteComponent with HasGameRef<FlappyBirdGame> {
  Background();
  @override
  Future<void> onLoad() async {
    final background = await Flame.images.load(Assets.backgroud);
    size = gameRef.size;
    sprite = Sprite(background);
  }
}
