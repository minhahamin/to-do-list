import 'package:flutter/material.dart';
import 'dart:js' as js;

class VoiceInputButton extends StatefulWidget {
  final Function(String) onText;

  const VoiceInputButton({super.key, required this.onText});

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton> {
  bool _isListening = false;

  void _startListening() {
    try {
      // 음성 인식 지원 확인
      final hasRecognition = js.context.hasProperty('webkitSpeechRecognition');
      
      if (!hasRecognition) {
        _showNotSupported();
        return;
      }

      setState(() {
        _isListening = true;
      });

      // JavaScript 코드로 음성 인식 실행
      js.context.callMethod('eval', ['''
        (function() {
          const recognition = new webkitSpeechRecognition();
          recognition.lang = 'ko-KR';
          recognition.continuous = false;
          recognition.interimResults = false;
          
          recognition.onresult = function(event) {
            const text = event.results[0][0].transcript;
            window.flutterVoiceResult = text;
          };
          
          recognition.onerror = function() {
            window.flutterVoiceError = true;
          };
          
          recognition.onend = function() {
            window.flutterVoiceEnded = true;
          };
          
          recognition.start();
        })();
      ''']);

      // 결과 폴링
      _pollForResult();
    } catch (e) {
      setState(() {
        _isListening = false;
      });
      _showError();
    }
  }

  void _pollForResult() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted || !_isListening) return;

      try {
        final result = js.context['flutterVoiceResult'];
        final error = js.context['flutterVoiceError'];
        final ended = js.context['flutterVoiceEnded'];

        if (result != null) {
          widget.onText(result.toString());
          js.context.deleteProperty('flutterVoiceResult');
          setState(() {
            _isListening = false;
          });
          return;
        }

        if (error != null) {
          js.context.deleteProperty('flutterVoiceError');
          setState(() {
            _isListening = false;
          });
          _showError();
          return;
        }

        if (ended != null) {
          js.context.deleteProperty('flutterVoiceEnded');
          setState(() {
            _isListening = false;
          });
          return;
        }

        _pollForResult();
      } catch (e) {
        setState(() {
          _isListening = false;
        });
      }
    });
  }

  void _showNotSupported() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('음성 인식이 지원되지 않는 브라우저입니다.\n(Chrome 권장)'),
      ),
    );
  }

  void _showError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('음성 인식 실패')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'voice_button',  // Hero 태그 중복 방지
      onPressed: _isListening ? null : _startListening,
      backgroundColor: _isListening ? Colors.red : Colors.deepPurple.shade300,
      child: _isListening
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Icon(Icons.mic_none, color: Colors.white),
    );
  }
}
