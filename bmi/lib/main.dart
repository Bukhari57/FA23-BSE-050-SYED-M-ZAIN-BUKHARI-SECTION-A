import 'package:flutter/material.dart';

void main() {
  runApp(const BMICalculator());
}

class BMICalculator extends StatelessWidget {
  const BMICalculator({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF0A0E21),
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A0E21),
        ),
      ),
      home: const InputPage(),
    );
  }
}

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI CALCULATOR'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: ReusableCard(colour: const Color(0xFF1D1E33)),
                ),
                Expanded(
                  child: ReusableCard(colour: const Color(0xFF1D1E33)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ReusableCard(colour: const Color(0xFF1D1E33)),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: ReusableCard(colour: const Color(0xFF1D1E33)),
                ),
                Expanded(
                  child: ReusableCard(colour: const Color(0xFF1D1E33)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReusableCard extends StatelessWidget {
  final Color colour;
  final Widget? cardChild;

  const ReusableCard({super.key, required this.colour, this.cardChild});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: colour,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: cardChild,
    );
  }
}