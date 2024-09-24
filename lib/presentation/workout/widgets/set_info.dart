import 'package:flutter/material.dart';

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