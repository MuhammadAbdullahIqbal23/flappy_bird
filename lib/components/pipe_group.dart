// ignore_for_file: non_constant_identifier_names

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
  PipeGroup();

  final _random = Random();

  @override
  Future<void> onLoad() async {
    position.x = gameRef.size.x;

    final HeightMinusGround = gameRef.size.y - Config.groundHeight;
    final spacing = 100 + _random.nextDouble() * (HeightMinusGround / 4);
    final centerY =
        spacing + _random.nextDouble() * (HeightMinusGround - spacing);
    addAll([
      Pipe(height: centerY - spacing / 2, pipePosition: PipePosition.top),
      Pipe(
          height: HeightMinusGround - (centerY + spacing / 2),
          pipePosition: PipePosition.bottom),
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
