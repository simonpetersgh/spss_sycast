// Stream provider for managing live stream data and state

// providers/stream_provider.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

import '../services/audio_service.dart';

class StreamProvider extends ChangeNotifier {
  final AudioService _audioService = AudioService();
  String _currentTitle = "SPS Livestream";
  int _listenerCount = 0;
  bool _isPlaying = false;

  String get currentTitle => _currentTitle;
  int get listenerCount => _listenerCount;
  bool get isPlaying => _isPlaying;
  AudioPlayer get player => _audioService.player;

  StreamProvider() {
    _init();
    _startStatsPolling();
  }

  void _init() {
    _audioService.initLiveStream("https://livestream.thesps.online/stream", "SPS Livestream");

    // Listen for ICY metadata changes (Stream Title)
    _audioService.player.icyMetadataStream.listen((metadata) {
      if (metadata != null && metadata.info != null) {
        _currentTitle = metadata.info!.title ?? "SPS Studio Livestream";
        notifyListeners();
      }
    });

    _audioService.player.playingStream.listen((playing) {
      _isPlaying = playing;
      notifyListeners();
    });
  }

  void togglePlay() {
    if (_isPlaying) {
      _audioService.player.pause();
    } else {
      _audioService.player.play();
    }
  }

  // Poll the Supabase Edge Function every 30 seconds for listener counts
  void _startStatsPolling() async {
    Timer.periodic(Duration(seconds: 30), (timer) async {
      final response = await http.get(
        Uri.parse('YOUR_SUPABASE_EDGE_FUNCTION_URL'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _listenerCount = data['listeners'];
        notifyListeners();
      }
    });
  }
}
