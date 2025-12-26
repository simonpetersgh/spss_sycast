import 'dart:async';
import 'dart:convert';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../services/audio_service.dart';
import '../services/podcast_service.dart';
import '../services/supabase_service.dart';

enum StreamStatus { checking, available, offline }

enum PodcastStatus { loading, loaded, error }

enum ActiveAudioType { none, livestream, podcast }

class AppProvider extends ChangeNotifier {
  // NEEDED SERVICES INSTANCES
  final SupabaseService _supabase = SupabaseService();
  final AudioService audio = AudioService();
  final PodcastService _podcastService = PodcastService();

  // STREAMING AUDIO STATES
  // NEW: Track what is actually playing
  ActiveAudioType _activeType = ActiveAudioType.none;
  ActiveAudioType get activeType => _activeType;

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

  String? _activeEpisodeUrl;

  // constructor
  AppProvider() {
    // 1. Do the heavy lifting while the splash is still showing
    _init();

    // LISTEN TO COMBINED PLAYER STATE
    audio.player.processingStateStream.listen((state) {
      // Logic: Only show 'Loading' if we are in the absolute initial loading phase
      // or if the player is idling but trying to load.
      notifyListeners();
    });

    // LISTEN TO PLAYER STATE CHANGES
    audio.player.playerStateStream.listen((state) {
      // This ensures that when the song finishes naturally,
      // the play/pause icons and visualizers reset immediately.
      if (state.processingState == ProcessingState.completed) {
        audio.player.stop(); // This resets the seek position to 0:00
      }
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

    fetchPodcasts();  // Fetch the initial batch of podcasts on startup

    // 3. NOW remove the splash screen
  FlutterNativeSplash.remove(); 
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
  Future<void> refreshStream() async {
    _streamStatus = StreamStatus.checking; // Force UI into loading mode
    notifyListeners(); // This makes the Player Card show the loading state immediately
    // Re-check availability
    await checkStreamAvailability(); // Reuse your existing logic to check state
  }

  // Only returns true if the player is playing AND it's the live stream
  bool get isLiveStreamPlaying {
    return _activeType == ActiveAudioType.livestream &&
        audio.player.playing &&
        audio.player.processingState != ProcessingState.loading;
  }

  // LIVE STREAM TOGGLE PLAY/PAUSE
  void toggleStreamPlay() async {
    // 1. If we were playing a podcast, stop it completely first kill it
    if (_activeType == ActiveAudioType.podcast) {
      await audio.player.stop();
      _activeEpisodeUrl = null;
    }

    // 2. Set the new type
    _activeType = ActiveAudioType.livestream;

    if (audio.player.playing) {
      await audio.player.pause();
    } else {
      // handle the play state
      try {
        // 3. FORCE RE-INITIALIZATION
        // We MUST re-init the live stream URL if it wasnt paused
        // and then start playing
        await audio.initLiveStream(streamUrl);
        // 4. Await play to ensure the handshake is solid
        await audio.player.play();
      } catch (e) {
        debugPrint("Stream Error: $e");
      }
    }

    notifyListeners();
  }

  // FETCH PODCASTS METHOD
  Future<void> fetchPodcasts() async {
    _podcastStatus = PodcastStatus.loading;
    notifyListeners();
    // This makes the PodcastListView show the loading circle immediately

    try {
      _episodes = await _podcastService.fetchEpisodes();
      _podcastStatus =
          _episodes.isEmpty ? PodcastStatus.loaded : PodcastStatus.loaded;
    } catch (e) {
      _podcastStatus = PodcastStatus.error;
    }
    notifyListeners();
  }

  //IS EPISODE ACTIVE HELPER BOOL
  // Only returns true if the player is playing AND it's this specific podcast
  bool isEpisodeActive(String url) {
    return _activeType == ActiveAudioType.podcast &&
        _activeEpisodeUrl == url &&
        audio.player.playing &&
        audio.player.processingState != ProcessingState.completed;
  }

  // 1. DYNAMIC PODCAST TOGGLE (Handles Play & Pause)
  // Updated the togglePlayPause method for better play/pause/resume logic
  // Handles the 3 states: Resume (same URL, not playing),
  // Pause (same URL, playing), and New Load (different URL).
  void togglePlayPausePodcast(PodcastEpisode ep) async {
    // If we were playing the Live Stream, stop it first
    if (_activeType == ActiveAudioType.livestream) {
      await audio.player.stop();
    }

    _activeType = ActiveAudioType.podcast;

    if (_activeEpisodeUrl == ep.audioUrl) {
      // Resume/Pause existing podcast
      // If it's the same episode, just toggle play/pause
      if (audio.player.playing) {
        await audio.player.pause();
      } else {
        audio.player.play();
      }
    } else {
      // Load a NEW podcast
      // If it's a new episode, stop previous and load new
      _activeEpisodeUrl = ep.audioUrl;
      await audio.player.stop(); // Clear old stream

      // Use await on setUrl to ensure the podcast metadata is loaded
      // BEFORE the play command is issued.
      await audio.player.setUrl(
        ep.audioUrl,
        tag: MediaItem(
          id: ep.audioUrl,
          title: ep.title,
          album: "LiveCast Podcast",
          artUri: Uri.parse(ep.imageUrl),
        ),
      );
      await audio.player.play(); // play
    }
    notifyListeners();
  }

  // 2. STOP METHOD
  void stopPostcastAudio() async {
    await audio.player.stop();
    // Sets playing to false and position to 0
    _activeEpisodeUrl = null;
    notifyListeners();
  }

  // 3. SEEK METHOD (Ensures state updates)
  void seek(Duration position) {
    audio.player.seek(position);
    notifyListeners();
  }

  // // PLAY PODCAST
  // // LOGIC TO SWITCH FROM LIVE TO PODCAST
  // void playPodcast(PodcastEpisode ep) async {
  //   // Track which one is playing
  //   _activeEpisodeUrl = ep.audioUrl;

  //   // 1. Stop or Pause Episode (if playing)
  //   // Toggle play/pause if the same episode is tapped
  //   if (audio.player.playing &&
  //       audio.player.audioSource?.toString().contains(ep.audioUrl) == true) {
  //     await audio.player.pause();
  //   } else {
  //     // 2. Play the podcast audio (Load if different)
  //     // If a different episode is selected while one is playing, stop it first
  //     await audio.player.stop();
  //     // await audio.player.setUrl(ep.audioUrl);
  //     // audio.player.play();
  //     // 3. Set Episode & Play
  //     await audio.player.setUrl(
  //       ep.audioUrl,
  //       tag: MediaItem(
  //         id: ep.audioUrl,
  //         title: ep.title,
  //         album: "LiveCast Podcast",
  //         artUri: Uri.parse(ep.imageUrl),
  //       ),
  //     );
  //     audio.player.play(); // PLAY: Don't await play to let streams handle state
  //   }

  //   notifyListeners();
  // }

  // SEND COMMENT TO SUPABASE
  Future<void> sendComment(String content, String username) async {
    await _supabase.postComment(content, username);
  }
}
