import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flappy_bird/components/pipe.dart';
import 'package:flappy_bird/game/FlappyBirdGame.dart';
import 'package:flappy_bird/game/assets.dart';
import 'package:flappy_bird/game/configuration.dart';
import 'package:flappy_bird/game/pipe_position.dart';
import 'package:flutter/material.dart';

class PipeGroup extends PositionComponent with HasGameRef<FlappyBirdGame> {
  final Difficulty difficulty;

  PipeGroup({required this.difficulty});

  final _random = Random();

  @override
  Future<void> onLoad() async {
    position.x = gameRef.size.x;

    final heightMinusGround = gameRef.size.y - Config.groundHeight;
    double spacing;

    switch (difficulty) {
      case Difficulty.easy:
        spacing = 170;
        break;
      case Difficulty.medium:
        spacing = 150 + _random.nextDouble() * 20;
        break;
      case Difficulty.hard:
        spacing = 130 + _random.nextDouble() * 20;
        break;
    }

    final centerY =
        spacing + _random.nextDouble() * (heightMinusGround - spacing);
    addAll([
      Pipe(
        height: centerY - spacing / 2,
        pipePosition: PipePosition.top,
      ),
      Pipe(
        height: heightMinusGround - (centerY + spacing / 2),
        pipePosition: PipePosition.bottom,
      ),
    ]);
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.x -= Config.gameSpeed * dt;

    if (position.x < -10) {
      removeFromParent();
      debugPrint('removed');
      updateScore();
    }
    if (game.isHit) {
      removeFromParent();
      game.isHit = false;
      gameRef.bird.score = 0;
    }
  }

  void updateScore() {
    gameRef.bird.score += 1;
    FlameAudio.play(Assets.point);
  }
}
