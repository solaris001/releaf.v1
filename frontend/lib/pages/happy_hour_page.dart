import 'package:releaf/pages/pages.dart';
import 'package:releaf/pages/happy_hour_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HappyHourPage extends StatefulWidget {
  const HappyHourPage({super.key});

  @override
  State<HappyHourPage> createState() => _HappyHourPageState();
}

class _HappyHourPageState extends State<HappyHourPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Happy Hour'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ListView(
              shrinkWrap: true,
              children: [
                FilledTextField(),
                FilledTextField(),
                FilledTextField(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FilledTextField extends StatefulWidget {
  const FilledTextField({super.key});

  @override
  State<FilledTextField> createState() => _FilledTextFieldState();
}

class _FilledTextFieldState extends State<FilledTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        suffixIcon: Icon(Icons.clear),
        filled: true,
      ),
      controller: _controller,
      onSubmitted: (String value) async {
        await showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Thanks!'),
              content: Text(
                  'You typed "$value", which has length ${value.characters.length}.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
