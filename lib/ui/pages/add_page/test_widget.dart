import 'package:flutter/material.dart';

class StepGoalWidget extends StatefulWidget {
  const StepGoalWidget({Key? key}) : super(key: key);

  @override
  State<StepGoalWidget> createState() => _StepGoalWidgetState();
}

class _StepGoalWidgetState extends State<StepGoalWidget> {
  int _selectedGoal = 6500;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Установить норму'),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Установите запланированное значение количества шагов в день, чтобы оставаться активными и здоровыми.',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 24),
              const Text(
                'Число шагов в день',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    final goal = 6400 + index * 100;
                    return ListTile(
                      title: Text(
                        '$goal',
                        style: TextStyle(
                          color: _selectedGoal == goal
                              ? Colors.blue
                              : Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedGoal = goal;
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}