import 'package:flutter/material.dart';

class BottomSection extends StatelessWidget {
  const BottomSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _searchField(context),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Call finish workout
            },
            child: const Text('Finish Workout'),
          ),
        ],
      ),
    );
  }

  Widget _searchField(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(
        hintText: 'Search Workout',
        prefixIcon: Icon(Icons.search),
      ).applyDefaults(
        Theme.of(context).inputDecorationTheme,
      ),
    );
  }
}
