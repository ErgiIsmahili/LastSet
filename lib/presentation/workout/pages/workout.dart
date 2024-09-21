import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:myapp/common/helpers/is_dark_mode.dart';
import 'package:myapp/common/widgets/appbar/app_bar.dart';
import 'package:myapp/common/widgets/button/basic_app_button.dart';
import 'package:myapp/core/configs/assets/app_images.dart';
import 'package:myapp/core/configs/assets/app_vectors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class WorkoutStorage {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveWorkout(String workoutName, Map<String, List<Map<String, dynamic>>> exercises) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final userWorkoutsRef = _firestore.collection('workouts').doc(user.uid);

    await _firestore.runTransaction((transaction) async {
      final userDoc = await transaction.get(userWorkoutsRef);

      if (!userDoc.exists) {
        transaction.set(userWorkoutsRef, {
          'workouts': {},
          'lastWorkouts': {},
        });
      }

      // Save the new workout
      transaction.set(userWorkoutsRef, {
        'workouts.$workoutName': exercises
      }, SetOptions(merge: true));

      // Update lastWorkouts for each exercise
      exercises.forEach((exerciseName, sets) {
        transaction.set(userWorkoutsRef, {
          'lastWorkouts.$exerciseName': sets
        }, SetOptions(merge: true));
      });
    });
  }

  Future<Map<String, dynamic>> getLastWorkout(String exerciseName) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final userWorkoutsRef = _firestore.collection('workouts').doc(user.uid);
    final userDoc = await userWorkoutsRef.get();

    if (!userDoc.exists) return {};

    final data = userDoc.data() as Map<String, dynamic>;
    final lastWorkouts = data['lastWorkouts'] as Map<String, dynamic>?;

    return lastWorkouts?[exerciseName] ?? {};
  }

  Stream<List<String>> getWorkoutNames() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    return _firestore
        .collection('workouts')
        .doc(user.uid)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data();
      final workouts = data?['workouts'] as Map<String, dynamic>?;
      return workouts?.keys.toList() ?? [];
    });
  }
}

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
          AppVectors.logo,
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

class SetInfo extends StatefulWidget {
  final int setNumber;
  final Map<String, dynamic>? lastSet;
  final Function(int setNumber, int weight, int reps) onSetCompleted;

  const SetInfo({
    required this.setNumber,
    this.lastSet,
    required this.onSetCompleted,
    super.key,
  });

  @override
  SetInfoState createState() => SetInfoState();
}

class SetInfoState extends State<SetInfo> {
  late TextEditingController _weightController;
  late TextEditingController _repsController;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(text: widget.lastSet?['weight']?.toString() ?? '');
    _repsController = TextEditingController(text: widget.lastSet?['reps']?.toString() ?? '');
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  double get previousWeight => (widget.lastSet?['weight']?.toDouble() ?? 0.0);

  double get previousReps => (widget.lastSet?['reps']?.toDouble() ?? 0.0);

  void _completeSet() {
    if (!_isCompleted) {
      setState(() {
        _isCompleted = true;
      });
      widget.onSetCompleted(
        widget.setNumber,
        int.tryParse(_weightController.text) ?? 0,
        int.tryParse(_repsController.text) ?? 0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Set'),
              Text('${widget.setNumber}'),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Previous'),
              Text('$previousWeight lb x $previousReps'),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('lbs'),
              SizedBox(
                width: 50,
                child: TextField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 5),
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('reps'),
              SizedBox(
                width: 50,
                child: TextField(
                  controller: _repsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 5),
                  ),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: _completeSet,
            child: Icon(
              _isCompleted ? Icons.check_circle : Icons.check_circle_outline,
              color: _isCompleted ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}