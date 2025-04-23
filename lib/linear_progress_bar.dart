import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Screen1(),
    );
  }
}

class Screen1 extends StatefulWidget
  @override
  _Screen1State createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> {
  double _progress = 0.2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Screen 1")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LinearProgressIndicator(value: _progress),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _progress += 0.3;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Screen2(progress: _progress)),
                );
              },
              child: Text("Next Screen"),
            ),
          ],
        ),
      ),
    );
  }
}

class Screen2 extends StatefulWidget {
  final double progress;

  Screen2({required this.progress});

  @override
  _Screen2State createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> {
  late double _progress;

  @override
  void initState() {
    super.initState();
    _progress = widget.progress;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Screen 2")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LinearProgressIndicator(value: _progress),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _progress += 0.3;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Screen3(progress: _progress)),
                );
              },
              child: Text("Next Screen"),
            ),
          ],
        ),
      ),
    );
  }
}

class Screen3 extends StatelessWidget {
  final double progress;

  Screen3({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Screen 3")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LinearProgressIndicator(value: progress),
            SizedBox(height: 20),
            Text(
              progress == 1.0 ? "Completed!" : "Progress: ${(progress * 100).toInt()}%",
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
