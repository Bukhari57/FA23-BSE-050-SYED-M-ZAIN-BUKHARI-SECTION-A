import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'reusable_card.dart';
import 'icon_content.dart';

const kActiveColor = Color(0xFF1D1E33);
const kInactiveColor = Color(0xFF111328);
const kBottomContainerColor = Color(0xFFEB1555);

enum Gender { male, female }

void main() => runApp(const BMICalculator());

class BMICalculator extends StatelessWidget {
  const BMICalculator({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
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

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  Gender? selectedGender;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BMI CALCULATOR')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: ReusableCard(
                    onPress: () => setState(() => selectedGender = Gender.male),
                    colour: selectedGender == Gender.male ? kActiveColor : kInactiveColor,
                    cardChild: const IconContent(icon: FontAwesomeIcons.mars, label: 'MALE'),
                  ),
                ),
                Expanded(
                  child: ReusableCard(
                    onPress: () => setState(() => selectedGender = Gender.female),
                    colour: selectedGender == Gender.female ? kActiveColor : kInactiveColor,
                    cardChild: const IconContent(icon: FontAwesomeIcons.venus, label: 'FEMALE'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ReusableCard(
              colour: kActiveColor,
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: ReusableCard(
                    colour: kActiveColor,
                  ),
                ),
                Expanded(
                  child: ReusableCard(
                    colour: kActiveColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}