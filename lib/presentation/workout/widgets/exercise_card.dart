import 'package:flutter/material.dart';
import 'package:myapp/core/configs/assets/app_images.dart';
import 'package:myapp/presentation/workout/widgets/set_info.dart';
import 'package:myapp/presentation/workout/widgets/workout_storage.dart';

class ExerciseCard extends StatefulWidget {
  final Map<String, dynamic> exercise;
  final Function(int setNumber, int weight, int reps) onSetCompleted;
  final WorkoutStorage workoutStorage;

  const ExerciseCard({
    required this.exercise,
    required this.onSetCompleted,
    required this.workoutStorage,
    super.key
  });

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  List<Map<String, dynamic>> lastWorkoutSets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLastWorkout();
  }

  Future<void> _fetchLastWorkout() async {
  try {
    final lastWorkout = await widget.workoutStorage.getLastWorkout(widget.exercise['name']);
    
    if (!mounted) return; 

    setState(() {
      lastWorkoutSets = List<Map<String, dynamic>>.from(lastWorkout['sets'] ?? [{'setNumber': 1, 'weight': 0, 'reps': 0},
    {'setNumber': 2, 'weight': 0, 'reps': 0},
    {'setNumber': 3, 'weight': 0, 'reps': 0},]);
      isLoading = false;
    });
  } catch (e) {
    if (!mounted) return; 

    setState(() {
      isLoading = false;
    });
    // Handle error (e.g., show a snackbar)
  }
}

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.exercise['name'],
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.favorite_border),
              ],
            ),
          ),
          Expanded(
            child: Image.asset(
              AppImages.arms,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      SizedBox(
                        height: 200,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              for (int i = 0; i < (lastWorkoutSets.length > 3 ? lastWorkoutSets.length : 3); i++)
                                SetInfo(
                                  setNumber: i + 1,
                                  lastSet: lastWorkoutSets.length > i ? lastWorkoutSets[i] : null,
                                  onSetCompleted: widget.onSetCompleted,
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            lastWorkoutSets.add({});
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('+ Add Set'),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}