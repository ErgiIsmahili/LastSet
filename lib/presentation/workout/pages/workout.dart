import 'package:flutter/material.dart';

class WorkoutPage extends StatelessWidget {
  final String workoutName;
  final String workoutImage;

  const WorkoutPage({
    required this.workoutName,
    required this.workoutImage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
        vertical: 50,
        horizontal: 50
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              workoutName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Image.asset(
                workoutImage,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Weight (kg):',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter weight in kg',
              ),
            ),
            const SizedBox(height: 20),

            // Reps Selection
            const Text(
              'Number of Reps:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter number of reps',
              ),
            ),
            const SizedBox(height: 20),

            // Add Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle adding the workout here
                },
                child: const Text('Add Workout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
