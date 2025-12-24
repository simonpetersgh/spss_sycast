import 'package:flutter/material.dart';
import 'dart:async';

import '../services/supabase_service.dart';
import '../services/audio_service.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/audio_service.dart';
import '../services/supabase_service.dart';
import '../services/podcast_service.dart';

enum StreamStatus { checking, online, offline }

class AppProvider extends ChangeNotifier {
  final AudioService audio = AudioService();
  final SupabaseService _supabase = SupabaseService();
  final PodcastService _podcast = PodcastService();

  StreamStatus streamStatus = StreamStatus.checking;
  bool hasPodcasts = true;
  int listeners = 0;
  String currentStreamTitle = "SPSS Studio";

  AppProvider() {
    _supabase.ensureAuth();
    checkStreamAvailability();
    // Poll every 60 seconds to see if the stream comes back online
    Timer.periodic(
      const Duration(seconds: 60),
      (_) => checkStreamAvailability(),
    );
  }

  // --- Intelligence: Stream Check ---
  Future<void> checkStreamAvailability() async {
    const streamUrl =
        "https://livestream.thesps.online/stream"; // The direct audio link
    try {
      // We do a HEAD request to check if the URL is reachable without downloading audio
      final response = await http
          .head(Uri.parse(streamUrl))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        streamStatus = StreamStatus.online;
        if (!audio.player.playing) {
          await audio.player.play(); // Pre-load if online
        }
      } else {
        streamStatus = StreamStatus.offline;
      }
    } catch (e) {
      streamStatus = StreamStatus.offline;
    }
    notifyListeners();
  }

  void togglePlay() {
    if (streamStatus == StreamStatus.online) {
      audio.player.playing ? audio.player.pause() : audio.player.play();
    }
  }

  // Helper for UI to check if podcasts exist
  Future<void> updatePodcastStatus(bool empty) async {
    if (hasPodcasts != !empty) {
      hasPodcasts = !empty;
      notifyListeners();
    }
  }

  Future<void> sendComment(String text, String name) async {
    await _supabase.postComment(text, name);
  }

  Stream<List<Map<String, dynamic>>> get commentsStream =>
      _supabase.getCommentsStream();
}

// class AppProvider extends ChangeNotifier {
//   final AudioService audio = AudioService();
//   final SupabaseService _supabase = SupabaseService();

//   String currentStreamTitle = "SPS Studio LiveStream";
//   bool isPlaying = false;
//   int listeners = 0;

//   AppProvider() {
//     _supabase.ensureAuth();
//     _initAudioListeners();
//   }

//   void _initAudioListeners() {
//     audio.player.playingStream.listen((playing) {
//       isPlaying = playing;
//       notifyListeners();
//     });

//     audio.player.icyMetadataStream.listen((meta) {
//       if (meta?.info?.title != null) {
//         currentStreamTitle = meta!.info!.title!;
//         notifyListeners();
//       }
//     });
//   }

//   void togglePlay() {
//     if (isPlaying) {
//       audio.player.pause();
//     } else {
//       audio.player.play();
//     }
//   }

//   Future<void> sendComment(String text, String name) async {
//     await _supabase.postComment(text, name);
//   }

//   // Getter for the comments stream to use in UI
//   Stream<List<Map<String, dynamic>>> get commentsStream =>
//       _supabase.getCommentsStream();
// }
