import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechToText extends StatefulWidget {
  const SpeechToText({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SpeechToTextState createState() => _SpeechToTextState();
}

class _SpeechToTextState extends State<SpeechToText> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  TextEditingController _textController = TextEditingController();
  // ignore: unused_field
  double _confidence = 1.0;
  String _currentLocaleId = 'en-US';
  final List<LocaleOption> _localeOptions = [
    LocaleOption('en-US', 'English'),
    LocaleOption('hi-IN', 'Hindi'),
  ];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _textController.text = 'Press the button and start speaking';
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _textController.text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
          }),
          localeId: _currentLocaleId, // Use the selected locale
          listenFor: const Duration(minutes: 1), // Adjust the duration as needed
          partialResults: true, // Enable partial results
        );
      } else {
        setState(() => _isListening = false);
        _speech.stop();
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record your disposition'),
      ),
      floatingActionButton: Center(
        child: FloatingActionButton(
          onPressed: _listen,
          child: Icon(_isListening ? Icons.mic : Icons.mic_none),
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              DropdownButton<LocaleOption>(
                value: _localeOptions.firstWhere((option) => option.localeId == _currentLocaleId),
                onChanged: (LocaleOption? newValue) {
                  setState(() {
                    _currentLocaleId = newValue!.localeId;
                    _textController.text = _currentLocaleId == 'en-US'
                        ? 'Press the button and start speaking'
                        : 'बटन दबाएं और बोलना शुरू करें';
                  });
                },
                items: _localeOptions.map<DropdownMenuItem<LocaleOption>>((LocaleOption option) {
                  return DropdownMenuItem<LocaleOption>(
                    value: option,
                    child: Text(option.name),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _textController,
                maxLines: null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Recognized Text',
                ),
                style: const TextStyle(fontSize: 25),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LocaleOption {
  final String localeId;
  final String name;

  LocaleOption(this.localeId, this.name);
}
