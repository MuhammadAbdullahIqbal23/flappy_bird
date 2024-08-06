import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flappy_bird/game/FlappyBirdGame.dart';
import 'package:flappy_bird/game/assets.dart';
import 'package:flappy_bird/game/bird_movement.dart';
import 'package:flappy_bird/game/configuration.dart';
import 'package:flutter/material.dart';

class Bird extends SpriteGroupComponent<BirdMovement>
    with HasGameRef<FlappyBirdGame>, CollisionCallbacks {
  Bird();
  int lives = 3;
  int lastCounterIncreaseScore = 0;
  int score = 0;
  bool isInvincible = false;
  late Timer invincibilityTimer;
  final double invincibilityDuration = 2.0; // 2 seconds of invincibility

  @override
  Future<void> onLoad() async {
    final birdMidFlap = await gameRef.loadSprite(Assets.birdMidFlap);
    final birdUpFlap = await gameRef.loadSprite(Assets.BirdUpFlap);
    final birddownFlap = await gameRef.loadSprite(Assets.BirdDownFlap);

    size = Vector2(50, 40);
    position = Vector2(50, gameRef.size.y / 2 - size.y / 2);
    current = BirdMovement.middle;
    sprites = {
      BirdMovement.middle: birdMidFlap,
      BirdMovement.up: birdUpFlap,
      BirdMovement.down: birddownFlap,
    };
    add(CircleHitbox());

    invincibilityTimer = Timer(invincibilityDuration);
  }

  void fly() {
    add(MoveByEffect(
      Vector2(0, Config.gravity),
      EffectController(duration: 0.2, curve: Curves.decelerate),
      onComplete: () => current = BirdMovement.down,
    ));
    current = BirdMovement.up;
    FlameAudio.play(Assets.flying);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (!isInvincible) {
      debugPrint('Collision Detected!!!');
      if (lives > 0) {
        lives--;
        resetPosition();
        debugPrint('$lives lives left');
      } else {
        gameOver();
      }
    }
  }

  void resetPosition() {
    position = Vector2(50, gameRef.size.y / 2 - size.y / 2);
    startInvincibility();
  }

  void startInvincibility() {
    isInvincible = true;
    invincibilityTimer.start();

    // Add blinking effect
    add(
      OpacityEffect.fadeOut(
        EffectController(
          duration: 0.2,
          alternate: true,
          infinite: true,
        ),
      )..onComplete = () {
          remove(children.last);
        },
    );
  }

  void endInvincibility() {
    isInvincible = false;
    opacity = 1.0; // Ensure full opacity when invincibility ends
    children.whereType<OpacityEffect>().forEach(remove);
  }

  void reset() {
    resetPosition();
    lives = 3; // Reset lives when starting a new game
    score = 0;
    lastCounterIncreaseScore = 0;
    endInvincibility();
  }

  void gameOver() {
    FlameAudio.play(Assets.collision);
    gameRef.overlays.add('gameOver');
    gameRef.pauseEngine();
    game.isHit = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += Config.birdVelocity * dt;

    invincibilityTimer.update(dt);
    if (invincibilityTimer.finished) {
      endInvincibility();
    }

    // Check if the score is a multiple of 5 and greater than 0
    if (score > 0 && score % 5 == 0 && score != lastCounterIncreaseScore) {
      lives++; // Increase lives
      lastCounterIncreaseScore = score;
      print('number of lives: $lives');
    }

    if ((position.y < 1 || position.y > gameRef.size.y) && !isInvincible) {
      if (lives > 0) {
        lives--;
        resetPosition();
      } else {
        gameOver();
      }
    }
  }
}
