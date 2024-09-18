import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myapp/common/helpers/is_dark_mode.dart';
import 'package:myapp/common/widgets/appbar/app_bar.dart';
import 'package:myapp/common/widgets/button/basic_app_button.dart';
import 'package:myapp/core/configs/assets/app_vectors.dart';
import 'package:myapp/presentation/workout/pages/workout.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => RootPageState();
}

class RootPageState extends State<RootPage> {
  final List<String> muscleGroups = [
    'abdominals', 'abductors', 'adductors', 'biceps', 'calves',
    'chest', 'forearms', 'glutes', 'hamstrings', 'lats',
    'lower_back', 'middle_back', 'neck', 'quadriceps', 'traps', 'triceps'
  ];

  Set<String> selectedMuscleGroups = {};

  void _onMuscleGroupSelect(String muscleGroup) {
    setState(() {
      if (selectedMuscleGroups.contains(muscleGroup)) {
        selectedMuscleGroups.remove(muscleGroup);
      } else {
        selectedMuscleGroups.add(muscleGroup);
      }
    });
  }

  void _onSubmit() {
    if (selectedMuscleGroups.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => WorkoutPage(
            workoutName: selectedMuscleGroups.join(', '),
            workoutImage: 'assets/images/custom_workout.jpg',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one muscle group.')),
      );
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
            isDarkMode ? Colors.white : Colors.black, BlendMode.srcIn)
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Select muscle groups for your workout:',
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: muscleGroups.length,
              itemBuilder: (context, index) {
                final muscleGroup = muscleGroups[index];
                final isSelected = selectedMuscleGroups.contains(muscleGroup);

                return InkWell(
                  onTap: () => _onMuscleGroupSelect(muscleGroup),
                  child: Card(
                    elevation: isSelected ? 8 : 2,
                    color: isSelected ? Theme.of(context).primaryColor : null,
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            muscleGroup.replaceAll('_', ' ').toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : null,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Positioned(
                            top: 8,
                            right: 8,
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Selected: ${selectedMuscleGroups.join(', ')}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            BasicAppButton(
              onPressed: _onSubmit,
              title: "Start Workout",
            ),
          ],
        ),
      ),
    );
  }
}