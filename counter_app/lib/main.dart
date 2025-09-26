import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'COUNTER CALCULATOR',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.tealAccent),
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'COUNTER CALCULATOR'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }
  void _addThreeCounter() {
    setState(() {
     _counter= _counter * _counter * _counter;
    });
  }
  void _decrementCounter() {
    setState(() {
      _counter--;
    });
  }

  void _multiplyCounter() {
    setState(() {
      _counter *= 2;
    });
  }

  void _squareCounter() {
    setState(() {
      _counter = _counter * _counter;
    });
  }

  void _equalCounter() {
    setState(() {
      _counter = _counter;
    });
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'THIS APP IS CHANGED BY SYED ZAIN BUKHARI',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              'Result: $_counter',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Wrap(
        spacing: 20,
        children: [
          FloatingActionButton(
            heroTag: "dec",
            onPressed: _decrementCounter,
            backgroundColor: Colors.red,
            child: const Icon(Icons.remove),
          ),
          FloatingActionButton(
            heroTag: "inc",
            onPressed: _incrementCounter,
            backgroundColor: Colors.green,
            child: const Icon(Icons.add),
          ),
          FloatingActionButton(
            heroTag: "mul",
            onPressed: _multiplyCounter,
            backgroundColor: Colors.blue,
            child: const Text("×"),
          ),
          FloatingActionButton(
            heroTag: "sq",
            onPressed: _squareCounter,
            backgroundColor: Colors.orange,
            child: const Text("x²"),
          ),
          FloatingActionButton(
            heroTag: "eq",
            onPressed: _equalCounter,
            backgroundColor: Colors.purple,
            child: const Text("="),
          ),
          FloatingActionButton(
            heroTag: "reset",
            onPressed: _resetCounter,
            backgroundColor: Colors.brown,
            child: const Icon(Icons.refresh),
          ),
          FloatingActionButton(
            heroTag: "cube",
            onPressed: _addThreeCounter,
            backgroundColor: Colors.orangeAccent,
            child: const Text("x^3"),
          ),
        ],
      ),
    );
  }
}
