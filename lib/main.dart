import 'package:flutter/material.dart';

void main() => runApp(const lg1());

class lg1 extends StatelessWidget {
  const lg1({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'lg1',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const lg2(),
    );
  }
}

class lg2 extends StatelessWidget {
  const lg2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'its time to orbit 🌍🛰️',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body:  Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [ // ✅ FIX: lowercase
             Card(
               elevation: 10,
               shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(20)
               ),
               shadowColor: Colors.blueAccent.withOpacity(0.30),
               child: Text('WELCOME TO INTERSTALLAR ORBIT '),
             )
          ],
        ),
      ),
    );
  }
}
