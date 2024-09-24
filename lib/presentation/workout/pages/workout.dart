import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:myapp/common/helpers/is_dark_mode.dart';
import 'package:myapp/common/widgets/appbar/app_bar.dart';
import 'package:myapp/common/widgets/button/basic_app_button.dart';
import 'package:myapp/core/configs/assets/app_vectors.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:myapp/presentation/workout/widgets/exercise_card.dart';
import 'package:myapp/presentation/workout/widgets/workout_storage.dart';

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
  final Map<String, List<Map<String, dynamic>>> workoutData = {};
  final WorkoutStorage _workoutStorage = WorkoutStorage();

  @override
  void initState() {
    super.initState();
    fetchExercises();
  }

  Future<void> fetchExercises() async {
  setState(() {
    isLoading = true;
  });

  try {
    final exercises = await Future.wait(
      widget.selectedMuscleGroups.map((muscle) => _fetchExercisesForMuscle(muscle))
    );

    if (!mounted) return; // Check if the widget is still in the tree

    setState(() {
      this.exercises = exercises.expand((e) => e).toList();
      isLoading = false;
    });
  } catch (e) {
    if (!mounted) return; // Check if the widget is still in the tree

    setState(() {
      isLoading = false;
    });
    _showErrorSnackBar('Failed to fetch exercises: $e');
  }
}

  Future<List<Map<String, dynamic>>> _fetchExercisesForMuscle(String muscle) async {
    final apiKey = dotenv.env['API_NINJA_KEY'] ?? '';

    if (apiKey.isEmpty) {
      throw Exception('API Key is not available');
    }

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

  void _saveSetData(String exerciseName, int setNumber, int weight, int reps) {
    if (!workoutData.containsKey(exerciseName)) {
      workoutData[exerciseName] = [];
    }
    workoutData[exerciseName]!.add({
      'setNumber': setNumber,
      'weight': weight,
      'reps': reps,
    });
  }

  Future<void> _finishWorkout() async {
    if (!mounted) return;

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      _showErrorSnackBar('No internet connection. Please check your network and try again.');
      return;
    }

    try {
      final workoutName = 'Workout ${DateTime.now().toIso8601String()}';
      await _workoutStorage.saveWorkout(workoutName, workoutData);

      if (!mounted) return;
      _showSuccessSnackBar('Workout saved successfully!');
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('An error occurred while saving the workout. Please try again.');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = context.isDarkMode;

    return Scaffold(
      appBar: BasicAppBar(
        title: SvgPicture.asset(
          AppVectors.logoWord,
          height: 40,
          width: 40,
          colorFilter: ColorFilter.mode(
            isDarkMode ? Colors.white : Colors.black, BlendMode.srcIn),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : exercises.isEmpty
              ? const Center(child: Text('No exercises found for the selected muscle groups.'))
              : Column(
                  children: [
                    Expanded(
                      child: Swiper(
                        itemBuilder: (BuildContext context, int index) {
                          return ExerciseCard(
                            exercise: exercises[index],
                            onSetCompleted: (setNumber, weight, reps) {
                              _saveSetData(exercises[index]['name'], setNumber, weight, reps);
                            },
                            workoutStorage: _workoutStorage,
                          );
                        },
                        itemCount: exercises.length,
                        viewportFraction: 0.8,
                        scale: 0.9,
                      ),
                    ),
                    _buildBottomSection(context),
                  ],
                ),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _searchField(context),
          const SizedBox(height: 20),
          BasicAppButton(
            onPressed: _finishWorkout,
            title: 'Finish Workout',
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
        Theme.of(context).inputDecorationTheme
      ),
    );
  }
}
