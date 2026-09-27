import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 1',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.black),
      ),
      home: const MyHomePage(title: 'Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({required this.title, super.key});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _inputController = TextEditingController();

  int _counter = 0;
  
  void _processInput() {
    final String inputValue = _inputController.text.trim();

    if (_formKey.currentState!.validate()) {
      setState(() {
        if (inputValue == 'Avada Kedavra') {
          _counter = 0;
        } else {
          final int number = int.parse(inputValue);
          _counter += number; 
        }
      });
    }
    _inputController.clear();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                '$_counter',
                style: const TextStyle(
                  fontSize: 80, fontWeight: FontWeight.bold
                ),
              ),
              
              TextFormField(
                controller: _inputController,
                decoration: const InputDecoration(
                  labelText: 'Input',
                  border: OutlineInputBorder(),
                  errorStyle: TextStyle(color: Colors.redAccent),
                ),
                validator: (value) {
                  final text = value?.trim();
                  if (text == null || text.isEmpty) {
                    return 'Field must not be empty!';
                  }
                  if (text == 'Avada Kedavra') {
                    return null;
                  }
                  if (int.tryParse(text) != null) {
                    return null;
                  }
                  return 'Only integers or "Avada Kedavra" are allowed.';
                },
              ),
        
              ElevatedButton(
                onPressed: _processInput,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40, vertical: 10
                  ),
                ),
                child: const Text(
                  'Enter',
                  style: TextStyle(fontSize: 25),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
