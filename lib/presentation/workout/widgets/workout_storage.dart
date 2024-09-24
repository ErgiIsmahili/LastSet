import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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