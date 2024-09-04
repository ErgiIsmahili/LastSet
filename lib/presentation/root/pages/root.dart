import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myapp/common/helpers/is_dark_mode.dart';
import 'package:myapp/common/widgets/appbar/app_bar.dart';
import 'package:myapp/common/widgets/button/basic_app_button.dart';
import 'package:myapp/common/widgets/card/workout_day_card.dart';
import 'package:myapp/core/configs/assets/app_vectors.dart';
import 'package:myapp/presentation/workout/pages/workout.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  final List<Map<String, String>> workoutDays = [
    {'name': 'Push Workout', 'image_url': 'assets/images/push.jpg'},
    {'name': 'Pull Workout', 'image_url': 'assets/images/pull.png'},
    {'name': 'Leg Workout', 'image_url': 'assets/images/legs.jpg'},
    {'name': 'Upper Body Workout', 'image_url': 'assets/images/upper.jpg'},
    {'name': 'Arm Workout', 'image_url': 'assets/images/arms.jpg'},
    {'name': 'Accessories', 'image_url': 'assets/images/accessories.png'},
    {'name': 'Chest/Back', 'image_url': 'assets/images/chest_back.jpg'},
    {'name': 'Chest/Bi', 'image_url': 'assets/images/chest_bi.png'},
    {'name': 'Back/Tri', 'image_url': 'assets/images/back_tri.jpg'},
    {'name': 'Fullbody Workout', 'image_url': 'assets/images/fullbody.png'},
  ];

  String? selectedDay;

  void _onCardTap(String day) {
    setState(() {
      selectedDay = day;
    });
  }

  void _onSubmit() {
    if (selectedDay != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const WorkoutPage(workoutName: 'Push-up', workoutImage: 'assets/images/chest_back.jpg',)
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a workout day.')),
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
      body: ListView.builder(
        itemCount: workoutDays.length,
        itemBuilder: (context, index) {
          final workoutDay = workoutDays[index];
          final title = workoutDay['name']!;
          final imageUrl = workoutDay['image_url']!;

          return WorkoutDayCard(
            title: title,
            imageUrl: imageUrl,
            isSelected: selectedDay == title,
            onTap: () => _onCardTap(title),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BasicAppButton(
          onPressed: _onSubmit,
          title: "Start Workout",
        ),
      ),
    );
  }
}
