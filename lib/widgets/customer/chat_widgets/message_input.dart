import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:jpmfood/data/config/app_colors.dart';

class MessageInput extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSubmit;

  const MessageInput({
    Key? key,
    required this.controller,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() {
            _isListening = false;
          });
        }
      },
      onError: (error) {
        setState(() {
          _isListening = false;
        });
        print('Speech recognition error: $error');
      },
    );
    setState(() {});
  }

  Future<void> _toggleListening() async {
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speech recognition not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_isListening) {
      await _speech.stop();
      setState(() {
        _isListening = false;
      });
    } else {
      setState(() {
        _isListening = true;
      });

      await _speech.listen(
        onResult: (result) {
          setState(() {
            widget.controller.text = result.recognizedWords;
          });

          // If user stops speaking and we have text, auto-submit
          if (result.finalResult && result.recognizedWords.isNotEmpty) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (_isListening) {
                _speech.stop();
                setState(() {
                  _isListening = false;
                });
                widget.onSubmit(widget.controller.text);
              }
            });
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        cancelOnError: true,
        partialResults: true,
        listenMode: stt.ListenMode.confirmation,
      );
    }
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Voice button
            Container(
              decoration: BoxDecoration(
                color: _isListening ? AppColors.danger : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: _isListening ? AppColors.textLight : Colors.grey[700],
                ),
                onPressed: _toggleListening,
                tooltip: _isListening ? 'Stop recording' : 'Voice input',
              ),
            ),
            const SizedBox(width: 8),
            // Text input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: widget.controller,
                  decoration: InputDecoration(
                    hintText: _isListening
                        ? 'Listening...'
                        : 'Ask me anything about food...',
                    hintStyle: TextStyle(
                      color: _isListening ? Colors.red : Colors.grey[500],
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: widget.onSubmit,
                  enabled: !_isListening,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Send button
            Container(
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: AppColors.textLight),
                onPressed: () => widget.onSubmit(widget.controller.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
