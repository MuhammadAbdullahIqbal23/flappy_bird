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
  int lives = 1;
  int lastCounterIncreaseScore = 0;
  int score = 0;
  bool isInvincible = false;
  late Timer invincibilityTimer;
  final double normalInvincibilityDuration = 2.0;
  final double powerUpInvincibilityDuration = 5.0;
  int lastPowerUpScore = 0;

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

    invincibilityTimer = Timer(normalInvincibilityDuration);
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

  void activatePowerUp() {
    startInvincibility(powerUpInvincibilityDuration);
    print('Power-up invincibility activated for 5 seconds!');
    // You might want to add a special sound effect here
    // FlameAudio.play(Assets.powerUp);
  }

  void resetPosition() {
    position = Vector2(50, gameRef.size.y / 2 - size.y / 2);
    startInvincibility(normalInvincibilityDuration);
  }

  void startInvincibility(double duration) {
    isInvincible = true;
    invincibilityTimer.stop();
    invincibilityTimer = Timer(duration);
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
    lives = 1;
    score = 0;
    lastCounterIncreaseScore = 0;
    lastPowerUpScore = 0;
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

    // Check for score-based events
    if (score > lastCounterIncreaseScore) {
      // Check for power-up invincibility at multiples of 15
      if (score % 15 == 0 && score > lastPowerUpScore) {
        startInvincibility(powerUpInvincibilityDuration);
        lastPowerUpScore = score;
        print(
            'Power-up invincibility activated for 5 seconds at score $score!');
        // You might want to add a special sound effect here
        // FlameAudio.play(Assets.powerUp);
      }

      // Check for life increase every 5 points
      if (score % 5 == 0) {
        lives++;
        print('number of lives: $lives');
      }

      lastCounterIncreaseScore = score;
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
