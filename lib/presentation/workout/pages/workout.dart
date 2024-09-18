import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WorkoutPage extends StatefulWidget {
  final List<String> selectedMuscleGroups;

  const WorkoutPage({
    required this.selectedMuscleGroups,
    super.key,
  });

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  List<Map<String, dynamic>> exercises = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchExercises();
  }

  Future<void> fetchExercises() async {
    setState(() {
      isLoading = true;
    });

    final exercises = await Future.wait(
      widget.selectedMuscleGroups.map((muscle) => _fetchExercisesForMuscle(muscle))
    );

    setState(() {
      this.exercises = exercises.expand((e) => e).toList();
      isLoading = false;
    });
  }

  Future<List<Map<String, dynamic>>> _fetchExercisesForMuscle(String muscle) async {
    final apiKey = 'PdptD7Q2cyZeOpC8HEclaw==7XPb9YKy7O6hAGqT';
    final url = Uri.parse('https://api.api-ninjas.com/v1/exercises?muscle=$muscle');

    final response = await http.get(
      url,
      headers: {'X-Api-Key': apiKey},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>().take(5).toList();
    } else {
      throw Exception('Failed to load exercises for $muscle');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Workout: ${widget.selectedMuscleGroups.join(", ")}'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : exercises.isEmpty
              ? Center(child: Text('No exercises found for the selected muscle groups.'))
              : ListView.builder(
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    return ExerciseCard(exercise: exercise);
                  },
                ),
    );
  }
}

class ExerciseCard extends StatelessWidget {
  final Map<String, dynamic> exercise;

  const ExerciseCard({required this.exercise, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise['name'],
            ),
            SizedBox(height: 8),
            Text('Type: ${exercise['type']}'),
            Text('Muscle: ${exercise['muscle']}'),
            Text('Equipment: ${exercise['equipment']}'),
            SizedBox(height: 8),
            Text('Instructions:'),
            Text(exercise['instructions']),
          ],
        ),
      ),
    );
  }
}