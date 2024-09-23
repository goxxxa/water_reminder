import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:water_reminder/ui/pages/target_editor/target_editor_page.dart';

class ProgressBar extends StatefulWidget {
  final int target;
  final int currentWaterLevel;
  final ConfettiController confettiController;

  const ProgressBar(
      {required this.target,
      required this.currentWaterLevel,
      required this.confettiController,
      super.key});

  @override
  State<ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar> {
  static const Duration duration = Duration(seconds: 2);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 16.0, right: 16.0, bottom: 16.0, top: 8.0),
      child: Column(children: [
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
                Theme.of(context).colorScheme.tertiary,
              ]),
              borderRadius: BorderRadius.circular(50.0)),
          width: MediaQuery.of(context).size.width / 1.3,
          height: 40,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: AnimatedContainer(
                duration: duration,
                width: widget.target != 0
                    ? (MediaQuery.of(context).size.width / 1.3) -
                        ((MediaQuery.of(context).size.width / 1.3) /
                            widget.target *
                            widget.currentWaterLevel)
                    : MediaQuery.of(context).size.width / 1.3,
                height: 40,
                decoration: BoxDecoration(color: Colors.grey[400]),
                onEnd: () {
                  if (widget.currentWaterLevel >= widget.target) {
                    widget.confettiController.play();
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 4.0,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width / 1.4,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('0'),
              GestureDetector(
                onTap: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          const ChangeWaterTarget(),
                    ),
                  )
                },
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(15.0)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: Text('Цель: ${widget.target}'),
                    )),
              )
            ],
          ),
        ),
      ]),
    );
  }

  @override
  void dispose() {
    widget.confettiController.stop();
    super.dispose();
  }
}
