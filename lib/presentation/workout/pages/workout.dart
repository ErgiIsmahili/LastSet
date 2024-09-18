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
                          return ExerciseCard(exercise: exercises[index]);
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
            onPressed: () {
              // Implement finish workout logic
            },
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

class ExerciseCard extends StatelessWidget {
  final Map<String, dynamic> exercise;

  const ExerciseCard({required this.exercise, super.key});

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
                    exercise['name'],
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
            child: Column(
              children: [
                const SetInfo(setNumber: 1, previousWeight: 85, previousReps: 10),
                const SetInfo(setNumber: 1, previousWeight: 85, previousReps: 10),
                const SetInfo(setNumber: 1, previousWeight: 85, previousReps: 10),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {
                    // Implement add set logic
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
  final int previousWeight;
  final int previousReps;

  const SetInfo({
    required this.setNumber,
    required this.previousWeight,
    required this.previousReps,
    Key? key,
  }) : super(key: key);

  @override
  _SetInfoState createState() => _SetInfoState();
}

class _SetInfoState extends State<SetInfo> {
  late TextEditingController _weightController;
  late TextEditingController _repsController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(text: widget.previousWeight.toString());
    _repsController = TextEditingController(text: widget.previousReps.toString());
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Set'),
              Text('${widget.setNumber}'),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Previous'),
              Text('${widget.previousWeight} lb x ${widget.previousReps}'),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('lbs'),
              SizedBox(
                width: 50,
                child: TextField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 5),
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('reps'),
              SizedBox(
                width: 50,
                child: TextField(
                  controller: _repsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 5),
                  ),
                ),
              ),
            ],
          ),
          const Icon(Icons.check, color: Colors.green),
        ],
      ),
    );
  }
}
