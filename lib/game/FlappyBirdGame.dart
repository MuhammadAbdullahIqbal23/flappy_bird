import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flappy_bird/components/background.dart';
import 'package:flappy_bird/components/bird.dart';
import 'package:flappy_bird/components/ground.dart';
import 'package:flappy_bird/components/pipe_group.dart';
import 'package:flappy_bird/game/configuration.dart';
import 'package:flappy_bird/screens/main_menu_screen.dart';
import 'package:flutter/material.dart';

enum Difficulty { easy, medium, hard }

class FlappyBirdGame extends FlameGame with TapDetector, HasCollisionDetection {
  late Bird bird;
  late TextComponent score;
  late TextComponent livesDisplay;
  Timer interval = Timer(Config.pipeInterval, repeat: true);
  bool isHit = false;
  Difficulty difficulty = Difficulty.easy;
  int lastLifeAdded = 0;

  @override
  Future<void> onLoad() async {
    addAll([
      Background(),
      Ground(),
      bird = Bird(),
      score = buildScore(),
      livesDisplay = buildLivesDisplay(),
    ]);
    interval.onTick = () => add(PipeGroup(difficulty: difficulty));
    overlays.add(MainMenuScreen.id);
  }

  @override
  void onTap() {
    super.onTap();
    bird.fly();
  }

  @override
  void update(double dt) {
    super.update(dt);
    interval.update(dt);
    score.text = 'Score: ${bird.score}';
    livesDisplay.text = 'Lives: ${bird.lives}';

    // Update difficulty based on score
    if (bird.score >= 20) {
      difficulty = Difficulty.hard;
    } else if (bird.score >= 10) {
      difficulty = Difficulty.medium;
    }

    // Add a life every 5 points
    if (bird.score > 0 && bird.score % 5 == 0 && bird.score != lastLifeAdded) {
      bird.lives++;
      lastLifeAdded = bird.score;
    }

    // Check for game over
    if (bird.lives <= 0 && !isHit) {
      isHit = true;
      overlays.add('gameOver');
      pauseEngine();
    }
  }

  TextComponent buildScore() {
    return TextComponent(
      text: 'Score: 0',
      position: Vector2(size.x / 2, size.y / 2 * 0.2),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          fontFamily: 'Game',
        ),
      ),
    );
  }

  TextComponent buildLivesDisplay() {
    return TextComponent(
      text: 'Lives: 3',
      position: Vector2(size.x / 2, size.y / 2 * 0.3),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          fontFamily: 'Game',
        ),
      ),
    );
  }
}
