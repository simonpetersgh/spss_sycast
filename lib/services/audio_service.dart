// Audio service for managing audio STREAM AND playback 
// services/audio_service.dart
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class AudioService {
  late AudioPlayer _player;

  AudioService() {
    _player = AudioPlayer();
  }

  AudioPlayer get player => _player;

  Future<void> initStream(String url) async {
    try {
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(url),
          tag: MediaItem(
            id: 'sps_live_stream',
            album: "SPSS LiveStream",
            title: "Live Stream",
            artUri: Uri.parse("https://firebasestorage.googleapis.com/v0/b/sesa-studio.firebasestorage.app/o/livecast%2FSPS%20Developer%20Logo.png?alt=media&token=79bee5ca-a5fc-4bd6-9871-626943bacb56"),
          ),
        ),
      );
    } catch (e) {
      debugPrint("Error loading stream: $e");
    }
  }
}