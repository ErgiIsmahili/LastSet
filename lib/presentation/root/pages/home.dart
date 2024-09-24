import 'package:flutter/material.dart';
import 'package:myapp/common/helpers/is_dark_mode.dart';
import 'package:myapp/presentation/root/pages/select_workout.dart';
import 'package:myapp/presentation/root/widgets/main_appbar.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  final List<String> workouts = [
    'Back & Biceps',
    'Chest & Triceps',
    'Legs',
    'Accessories',
    'Back & Triceps',
    'Chest & Biceps',
    'Full Body',
    "+"
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    bool isDarkMode = context.isDarkMode;

    return Scaffold(
       appBar: const MainAppBar(),
       body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Quickstart',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 200,
            child: PageView.builder(
              controller: _pageController,
              itemCount: workouts.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: colorScheme.primary, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        workouts[index],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),  
          Center(
            child: SmoothPageIndicator(
              controller: _pageController,
              count: workouts.length,
              effect: WormEffect(
                dotHeight: 12,
                dotWidth: 12,
                activeDotColor: colorScheme.primary,
                dotColor: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SelectWorkoutPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: isDarkMode ? Colors.white : Colors.black,
              ),
              child: Text(
                'Custom Workout',
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold, 
                  color: isDarkMode ? Colors.black : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
