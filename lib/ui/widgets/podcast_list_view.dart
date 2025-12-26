import 'package:flutter/material.dart';
import 'package:mini_music_visualizer/mini_music_visualizer.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../services/podcast_service.dart';
import 'formatter_helpers.dart';

class PodcastListView extends StatelessWidget {
  const PodcastListView({super.key});

  @override
  Widget build(BuildContext context) {
    // ----------------------------
    // We "watch" the provider so this widget rebuilds whenever notifyListeners() is called
    final prov = context.watch<AppProvider>();
    final mint = Theme.of(context).colorScheme.primary;

    // 1. LOADING STATE
    if (prov.podcastStatus == PodcastStatus.loading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
    }

    // 2. ERROR STATE
    if (prov.podcastStatus == PodcastStatus.error) {
      return SliverToBoxAdapter(child: _buildErrorState(prov));
    }

    // 3. EMPTY STATE
    if (prov.episodes.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Text(
            "No podcasts available for this channel.",
            style: TextStyle(color: Colors.white24),
          ),
        ),
      );
    }

    // 4. PODCAST DATA STATE (Modern List)
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final ep = prov.episodes[index];
        return _PodcastCard(ep: ep, mint: mint, prov: prov);
      }, childCount: prov.episodes.length),
    );
  }

  Widget _buildErrorState(AppProvider prov) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.wifi_off_rounded, color: Colors.white24, size: 40),
          const SizedBox(height: 12),
          const Text(
            "Failed to load podcasts. Check your internet connection and try again.",
            style: TextStyle(color: Colors.white70),
          ),
          TextButton(
            onPressed: () => prov.fetchPodcasts(),
            child: const Text("Tap to Reload"),
          ),
        ],
      ),
    );
  }
}

class _PodcastCard extends StatelessWidget {
  final dynamic ep;
  final Color mint;
  final AppProvider prov;

  const _PodcastCard({
    required this.ep,
    required this.mint,
    required this.prov,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: InkWell(
        // Open details/player view,
        // onTap: () => _showEpisodeDetails(context, ep, prov),
        onTap: () => _showEpisodeDetails(context, ep),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Episode Art
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  ep.imageUrl,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (c, e, s) => Container(
                        color: Colors.white10,
                        child: const Icon(Icons.mic, color: Colors.white24),
                      ),
                ),
              ),
              const SizedBox(width: 16),
              // Info Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Episode Title
                    Text(
                      ep.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Duration
                    Row(
                      children: [
                        if (ep.duration.isNotEmpty) ...[
                          Text(
                            // ep.duration,
                            formatDurationNumeric(ep.duration),
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 14,
                            ),
                          ),
                        ],
                        const SizedBox(width: 8),
                        // Publication Date
                        Text(
                          "•  ${ep.pubDate.toString().substring(0, 16)}", // Clean up RSS date
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),
                  ],
                ),
              ),
              // -----------------
              // PLAYING INDICATOR
              if (prov.isEpisodeActive(ep.audioUrl))
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: MiniMusicVisualizer(
                    color: mint,
                    width: 3,
                    animate: true,
                    height: 16,
                  ),
                ),
              const SizedBox(width: 8),
              // -----------------
              // Play Icon
              Container(
                // padding: const EdgeInsets.all(8),
                // decoration: BoxDecoration(
                //   color: mint.withOpacity(0.1),
                //   shape: BoxShape.circle,
                // ),
                child: GestureDetector(
                  onTap: () => prov.togglePlayPausePodcast(ep),
                  child: Icon(
                    // Dynamic logic: only show pause if this specific episode is playing
                    (prov.isEpisodeActive(ep.audioUrl))
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_filled_rounded,
                    color: mint,
                    size: 36,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // SHOW PODCAST DETAILS & PLAYER SHEET
  // void _showEpisodeDetails(
  //   BuildContext context,
  //   PodcastEpisode ep,
  //   AppProvider prov,
  // ) {
  //   final mint = Theme.of(context).colorScheme.primary;

  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder:
  //         (context) => Container(
  //           height: MediaQuery.of(context).size.height * 0.85,
  //           decoration: BoxDecoration(
  //             color: const Color(0xFF181C27), // Your background color
  //             borderRadius: const BorderRadius.vertical(
  //               top: Radius.circular(32),
  //             ),
  //           ),
  //           child: Column(
  //             children: [
  //               // Drag Handle
  //               Container(
  //                 margin: const EdgeInsets.symmetric(vertical: 15),
  //                 height: 5,
  //                 width: 45,
  //                 decoration: BoxDecoration(
  //                   color: Colors.white10,
  //                   borderRadius: BorderRadius.circular(10),
  //                 ),
  //               ),

  //               Expanded(
  //                 child: ListView(
  //                   padding: const EdgeInsets.symmetric(horizontal: 24),
  //                   children: [
  //                     // 1. Image & Title
  //                     Center(
  //                       child: ClipRRect(
  //                         borderRadius: BorderRadius.circular(24),
  //                         child: Image.network(
  //                           ep.imageUrl,
  //                           height: 280,
  //                           width: double.infinity,
  //                           fit: BoxFit.cover,
  //                         ),
  //                       ),
  //                     ),
  //                     const SizedBox(height: 24),
  //                     Text(
  //                       ep.title,
  //                       style: const TextStyle(
  //                         fontSize: 22,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),
  //                     const SizedBox(height: 8),
  //                     Text(
  //                       "SPS Studio • ${ep.pubDate}",
  //                       style: const TextStyle(color: Colors.white38),
  //                     ),

  //                     const SizedBox(height: 30),

  //                     // 2. REAL-TIME PROGRESS SLIDER
  //                     StreamBuilder<Duration>(
  //                       stream: prov.audio.player.positionStream,
  //                       builder: (context, snapshot) {
  //                         final position = snapshot.data ?? Duration.zero;
  //                         final total =
  //                             prov.audio.player.duration ?? Duration.zero;

  //                         return Column(
  //                           children: [
  //                             SliderTheme(
  //                               data: SliderTheme.of(context).copyWith(
  //                                 trackHeight: 4,
  //                                 thumbShape: const RoundSliderThumbShape(
  //                                   enabledThumbRadius: 6,
  //                                 ),
  //                                 overlayShape: const RoundSliderOverlayShape(
  //                                   overlayRadius: 14,
  //                                 ),
  //                                 activeTrackColor: mint,
  //                                 inactiveTrackColor: Colors.white10,
  //                                 thumbColor: mint,
  //                               ),
  //                               child: Slider(
  //                                 value: position.inSeconds.toDouble(),
  //                                 max:
  //                                     total.inSeconds.toDouble() > 0
  //                                         ? total.inSeconds.toDouble()
  //                                         : 1.0,
  //                                 onChanged:
  //                                     (val) => prov.seek(
  //                                       Duration(seconds: val.toInt()),
  //                                     ),
  //                               ),
  //                             ),
  //                             Padding(
  //                               padding: const EdgeInsets.symmetric(
  //                                 horizontal: 16,
  //                               ),
  //                               child: Row(
  //                                 mainAxisAlignment:
  //                                     MainAxisAlignment.spaceBetween,
  //                                 children: [
  //                                   Text(
  //                                     _formatTime(position),
  //                                     style: const TextStyle(
  //                                       color: Colors.white38,
  //                                       fontSize: 12,
  //                                     ),
  //                                   ),
  //                                   Text(
  //                                     _formatTime(total),
  //                                     style: const TextStyle(
  //                                       color: Colors.white38,
  //                                       fontSize: 12,
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
  //                           ],
  //                         );
  //                       },
  //                     ),

  //                     const SizedBox(height: 20),

  //                     // 3. PLAYER CONTROLS
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: [
  //                         // // STOP BUTTON
  //                         // IconButton(
  //                         //   icon: const Icon(
  //                         //     Icons.stop_rounded,
  //                         //     color: Colors.white54,
  //                         //     size: 30,
  //                         //   ),
  //                         //   onPressed: () {
  //                         //     prov.stopAudio();
  //                         //     Navigator.pop(
  //                         //       context,
  //                         //     ); // Optional: Close sheet on stop
  //                         //   },
  //                         // ),
  //                         // const SizedBox(width: 20),
  //                         // DYNAMIC PLAY/PAUSE BUTTON
  //                         GestureDetector(
  //                           onTap: () => prov.togglePlayPause(ep),
  //                           child: Container(
  //                             height: 70,
  //                             width: 70,
  //                             decoration: BoxDecoration(
  //                               color: mint,
  //                               shape: BoxShape.circle,
  //                             ),
  //                             child: Icon(
  //                               prov.isEpisodeActive(ep.audioUrl)
  //                                   ? Icons.pause_rounded
  //                                   : Icons.play_arrow_rounded,
  //                               color: Colors.black,
  //                               size: 40,
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                     const SizedBox(height: 30),

  //                     // 4. DESCRIPTION
  //                     const Text(
  //                       "Description",
  //                       style: TextStyle(
  //                         fontWeight: FontWeight.bold,
  //                         fontSize: 16,
  //                       ),
  //                     ),
  //                     const SizedBox(height: 10),
  //                     Text(
  //                       ep.description,
  //                       style: TextStyle(
  //                         color: Colors.white.withOpacity(0.6),
  //                         height: 1.5,
  //                       ),
  //                     ),
  //                     const SizedBox(height: 40),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //   );
  // }

  void _showEpisodeDetails(BuildContext context, PodcastEpisode ep) {
    final mint = Theme.of(context).colorScheme.primary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        // THE FIX: Wrap in Consumer so this specific UI reacts to the Provider
        return Consumer<AppProvider>(
          builder: (context, prov, child) {
            final isPlaying = prov.isEpisodeActive(ep.audioUrl);

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: const Color(0xFF181C27),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  // Drag Handle
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 15),
                    height: 5,
                    width: 45,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        // 1. Image & Title
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.network(
                              ep.imageUrl,
                              height: 280,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          ep.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "SPS Studio • ${ep.pubDate.toString().substring(0, 16)}",
                          style: const TextStyle(color: Colors.white38),
                        ),

                        const SizedBox(height: 30),

                        // PROGRESS SLIDER (This will now also update smoothly)
                        StreamBuilder<Duration>(
                          stream: prov.audio.player.positionStream,
                          builder: (context, snapshot) {
                            // 1. Get current position
                            final position = snapshot.data ?? Duration.zero;

                            // 2. Get total duration (Safely)
                            final total =
                                prov.audio.player.duration ?? Duration.zero;

                            // 3. LOGIC: Is the podcast in this sheet actually the one playing?
                            // If we are playing a LIVESTREAM, we should show 0 progress for the podcast
                            bool isThisEpPlaying = prov.isEpisodeActive(
                              ep.audioUrl,
                            );

                            // Use the player's values only if THIS podcast is the active audio
                            double currentVal =
                                isThisEpPlaying
                                    ? position.inSeconds.toDouble()
                                    : 0.0;
                            double maxVal =
                                (isThisEpPlaying && total.inSeconds > 0)
                                    ? total.inSeconds.toDouble()
                                    : 1.0; // Avoid divide by zero or null errors

                            return Column(
                              children: [
                                // PROGRESS SLIDER
                                Slider(
                                  value: currentVal.clamp(
                                    0.0,
                                    maxVal,
                                  ), // Ensure value is within range
                                  max: maxVal,
                                  onChanged:
                                      isThisEpPlaying
                                          ? (val) => prov.seek(
                                            Duration(seconds: val.toInt()),
                                          )
                                          : null, // Disable slider if not playing this episode
                                ),
                                // time indicators
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Current Time (Show 0:00 if this podcast isn't the one playing)
                                    Text(
                                      isThisEpPlaying
                                          ? formatTime(position)
                                          : "0:00",
                                      style: const TextStyle(
                                        color: Colors.white38,
                                        fontSize: 12,
                                      ),
                                    ),
                                    // Total Duration
                                    Text(
                                      isThisEpPlaying
                                          ? formatTime(total)
                                          : formatDurationNumeric(ep.duration),
                                      style: const TextStyle(
                                        color: Colors.white38,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 30),

                        // DYNAMIC CONTROLS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // PLAY/PAUSE BUTTON
                            GestureDetector(
                              onTap:
                                  () => prov.togglePlayPausePodcast(
                                    ep,
                                  ), // This will now trigger the Consumer rebuild
                              child: Container(
                                height: 70,
                                width: 70,
                                decoration: BoxDecoration(
                                  color: mint,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: Colors.black,
                                  size: 40,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // 4. DESCRIPTION
                        const Text(
                          "Description",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          ep.description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Helper to format Duration into 00:00
  String _formatTime(Duration d) {
    return d.toString().split('.').first.padLeft(8, "0").substring(3);
  }

  // END OF CLASS
}
