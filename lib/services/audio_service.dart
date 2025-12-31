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

  Future<void> initLiveStream(String streamUrl, String streamTitle) async {
    // Set the audio source to the live stream URL with metadata for notification
    // 'tag' is used by just_audio_background to show notification
    // Make sure to provide a unique ID and relevant info
    // notification artUri (album art) should be a valid URL
    String albumArtUrl = "https://firebasestorage.googleapis.com/v0/b/sesa-studio.firebasestorage.app/o/livecast%2Fstream-logo.png?alt=media&token=e18d50d1-bd20-47b3-b15b-5e0378cd064f";
    try {
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(streamUrl),
          // This 'tag' creates play notification
          tag: MediaItem(
            id: 'livecast-livestream',
            title: streamTitle, // This shows as the current playing song title in notification
            album: "LiveCast Livestream",
            artUri: Uri.parse(
              albumArtUrl
            ),
          ),
        ),
      );
    } catch (e) {
      debugPrint("Error loading stream: $e");
    }
  }
}
