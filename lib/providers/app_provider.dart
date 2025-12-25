import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../services/audio_service.dart';
import '../services/podcast_service.dart';
import '../services/supabase_service.dart';

enum StreamStatus { checking, available, offline }

enum PodcastStatus { loading, loaded, error }

class AppProvider extends ChangeNotifier {
  // NEEDED SERVICES INSTANCES
  final SupabaseService _supabase = SupabaseService();
  final AudioService audio = AudioService();
  final PodcastService _podcastService = PodcastService();

  // URLs for Icecast PC (Exposed via Cloudflare Tunnel)
  final String streamUrl = "https://livestream.thesps.online/stream";
  final String statusUrl = "https://livestream.thesps.online/status-json.xsl";

  // Stream Status
  StreamStatus _streamStatus = StreamStatus.checking;
  StreamStatus get streamStatus => _streamStatus;

  // Listener Count & Stream Title
  int _listeners = 0;
  int get listeners => _listeners;
  String _streamTitle = "SPS LiveCast"; // Default title
  String get streamTitle => _streamTitle;

  // PODCASTS STATES
  PodcastStatus _podcastStatus = PodcastStatus.loading;
  List<PodcastEpisode> _episodes = [];

  PodcastStatus get podcastStatus => _podcastStatus;
  List<PodcastEpisode> get episodes => _episodes;

  // constructor
  AppProvider() {
    _init();

    // LISTEN TO COMBINED PLAYER STATE
    audio.player.processingStateStream.listen((state) {
      // Logic: Only show 'Loading' if we are in the absolute initial loading phase
      // or if the player is idling but trying to load.
      notifyListeners();
    });

    // Poll Icecast every 10 seconds for listener counts
    Timer.periodic(
      const Duration(seconds: 10),
      (timer) => checkStreamAvailability(),
    );
  }

  Future<void> _init() async {
    await _supabase.ensureAuth();
    await checkStreamAvailability();
    fetchPodcasts();
  }

  // 2. STREAM STATUS HELPERS
  // Helper to check if the stream is currently "working" on something
  // like loading or buffering; will be used to show loading indicators in UI
  bool get isInitialLoading {
    final state = audio.player.processingState;
    // We only show the spinner if the player is strictly 'loading'.
    // We ignore 'buffering' here because Icecast often stays in buffering
    // for a few seconds even after audio starts.
    return state == ProcessingState.loading;
  }

  bool get isActuallyPlaying {
    // If the user has pressed play AND the player has moved past the loading stage
    return audio.player.playing &&
        (audio.player.processingState == ProcessingState.ready ||
            audio.player.processingState == ProcessingState.buffering);
  }

  Future<void> checkStreamAvailability() async {
    try {
      // Fetch Icecast stream status
      final response = await http
          .get(Uri.parse(statusUrl))
          .timeout(const Duration(seconds: 5));
      // handle response
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final icestats = data['icestats'];

        // Icecast JSON parsing (structure depends on your Icecast version)
        // Usually: icestats -> source
        // Check if there are any active sources
        if (icestats != null && icestats.containsKey('source')) {
          _streamStatus = StreamStatus.available;
          var source = icestats['source'];

          // Handle source as either a List (multiple mounts) or Map (single mount)
          // Icecast returns a List if multiple mounts are active, or a Map if only one.
          Map<String, dynamic> activeSource;
          if (source is List && source.isNotEmpty) {
            activeSource = source[0];
          } else {
            activeSource = source;
          }
          // OR SHORTCUT:
          // Map<String, dynamic> activeSource = (source is List) ? source[0] : source;

          // LISTENERS
          _listeners = activeSource['listeners'] ?? 0;

          // STREAM TITLE
          // EXTRACT TITLE: Try server_name first, then genre, then fallback
          _streamTitle =
              activeSource['server_name'] ??
              activeSource['genre'] ??
              "SyCast Stream";
        } else {
          _streamStatus = StreamStatus.offline;
        }
      } else {
        _streamStatus = StreamStatus.offline;
      }
    } catch (e) {
      _streamStatus = StreamStatus.offline;
    }
    notifyListeners();
  }

  // REFRESH STREAM STATUS
  Future<void> refreshStreamStatus() async {
    _streamStatus = StreamStatus.checking; // Force UI into loading mode
    notifyListeners();
    // Re-check availability
    await checkStreamAvailability(); // Reuse your existing logic to check state
  }

  void togglePlay() async {
    if (audio.player.playing) {
      // For live streams, pause often works better than stop
      // await audio.player.stop();
      await audio.player.pause();
    } else {
      // handle the play state
      try {
        // Only set source if it's not already set to avoid re-loading from scratch
        if (audio.player.audioSource == null) {
          await audio.initStream(streamUrl);
        }
        audio.player
            .play(); // Don't 'await' play, let the streams handle the state
      } catch (e) {
        debugPrint("Error: $e");
      }
    }

    notifyListeners();
  }

  // FETCH PODCASTS METHOD
  Future<void> fetchPodcasts() async {
    _podcastStatus = PodcastStatus.loading;
    notifyListeners();

    try {
      _episodes = await _podcastService.fetchEpisodes();
      _podcastStatus =
          _episodes.isEmpty ? PodcastStatus.loaded : PodcastStatus.loaded;
    } catch (e) {
      _podcastStatus = PodcastStatus.error;
    }
    notifyListeners();
  }

  // LOGIC TO SWITCH FROM LIVE TO PODCAST
  void playPodcast(PodcastEpisode ep) async {
    // 1. Stop current playback
    await audio.player.stop();
    // 2. Load the podcast audio URL
    await audio.player.setUrl(
      ep.audioUrl,
      tag: MediaItem(
        id: ep.audioUrl,
        title: ep.title,
        album: "LiveCast Podcast",
        artUri: Uri.parse(ep.imageUrl),
      ),
    );
    // 3. Play
    audio.player.play();
    notifyListeners();
  }

  Future<void> sendComment(String content, String username) async {
    await _supabase.postComment(content, username);
  }
}
