import 'package:flappy_bird/game/FlappyBirdGame.dart';
import 'package:flappy_bird/game/assets.dart';
import 'package:flutter/material.dart';

class MainMenuScreen extends StatelessWidget {
  final FlappyBirdGame game;
  static const String id = 'mainMenu';
  const MainMenuScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    game.pauseEngine();
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          game.overlays.remove('mainMenu');
          game.resumeEngine();
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(Assets.menu),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Flappy Bird',
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    game.difficulty = Difficulty.easy;
                    game.overlays.remove('mainMenu');
                    game.resumeEngine();
                  },
                  child: const Text('Easy'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    game.difficulty = Difficulty.medium;
                    game.overlays.remove('mainMenu');
                    game.resumeEngine();
                  },
                  child: const Text('Medium'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    game.difficulty = Difficulty.hard;
                    game.overlays.remove('mainMenu');
                    game.resumeEngine();
                  },
                  child: const Text('Hard'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
