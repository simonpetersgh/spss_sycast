import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mini_music_visualizer/mini_music_visualizer.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import 'widgets/comment_section.dart';
import 'widgets/podcast_list_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showComments = false;

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<AppProvider>(context);
    final theme = Theme.of(context);
    final primaryMint = theme.colorScheme.primary; // #1eddaa
    final accentPurple = theme.colorScheme.secondary; // #9549fe
    final isLive = prov.streamStatus == StreamStatus.available;
    final isChecking = prov.streamStatus == StreamStatus.checking;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // banner
              // 1. MODERN APP BAR WITH GRADIENT OVERLAY
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                stretch: true,
                backgroundColor: theme.scaffoldBackgroundColor,
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Featured Image/Art
                      Image.asset(
                        "assets/images/livecast-logo.png",
                        fit: BoxFit.cover,
                      ),
                      // Dark Overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              theme.scaffoldBackgroundColor.withOpacity(0.8),
                              theme.scaffoldBackgroundColor,
                            ],
                          ),
                        ),
                      ),
                      // Title Info
                      Positioned(
                        bottom: 60,
                        left: 20,
                        right: 20,
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildStatusBadge(prov, primaryMint),
                            const SizedBox(height: 8),
                            Text(
                              "SPS LiveCast | SyCast",
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. PLAYER DASHBOARD (Glassmorphic)
              // 2. MAIN PLAYER CARD
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child:
                      isChecking
                          ? const Center(child: CircularProgressIndicator())
                          : _buildPlayerCard(prov, isLive),
                ),
              ),

              // 3. CONDITIONAL STATS (Only if Live)
              // 3. STATS SECTION (ONLY SHOWS IF LIVE)
              if (isLive)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        _buildStatChip(
                          Icons.headset,
                          "${prov.listeners}",
                          "Listeners",
                          theme,
                        ),
                        const SizedBox(width: 12),
                        // Comment Toggle
                        _buildStatChip(
                          Icons.chat_bubble_outline,
                          "Live",
                          "Comments",
                          theme,
                          onTap:
                              () => setState(
                                () => _showComments = !_showComments,
                              ),
                          isActive: _showComments,
                        ),
                      ],
                    ),
                  ),
                ),

              // 4. CONDITIONAL COMMENTS SECTION
              // 4. COMMENT SECTION (ONLY SHOWS IF LIVE & TOGGLED)
              if (isLive && _showComments)
                const SliverToBoxAdapter(child: CommentSection()),

              // 5. PODCAST SECTION
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Text(
                    "On-demand Podcasts",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),

              const PodcastListView(),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),

          // Optional: Floating Play Button at the bottom for quick access
        ],
      ),
    );
  }

  Widget _buildStatChip(
    IconData icon,
    String value,
    String label,
    ThemeData theme, {
    VoidCallback? onTap,
    bool isActive = false,
  }) {
    final color =
        isActive ? theme.colorScheme.secondary : theme.colorScheme.primary;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color:
                isActive
                    ? color.withOpacity(0.1)
                    : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isActive ? color : Colors.white10),
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: isActive ? color : Colors.white54),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                label,
                style: const TextStyle(fontSize: 10, color: Colors.white38),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // STATUS BADGE (Live vs Offline)
  Widget _buildStatusBadge(AppProvider prov, Color mint) {
    bool isLive = prov.streamStatus == StreamStatus.available;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isLive ? mint.withOpacity(0.2) : Colors.white10,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isLive ? mint : Colors.white24, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isLive ? mint : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isLive ? "LIVE NOW" : "OFFLINE",
            style: TextStyle(
              color: isLive ? mint : Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  // STREAM PLAYER WIDGET
  Widget _buildPlayerCard(AppProvider prov, bool isLive) {
    final theme = Theme.of(context);
    final mint = theme.colorScheme.primary;

    // Use precise state helpers
    // final isPlaying = prov.audio.player.playing;
    final bool isLoading = prov.isInitialLoading;
    final bool isPlaying = prov.isActuallyPlaying;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isLive ? mint.withOpacity(0.3) : Colors.white10,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          if (!isLive) ...[
            // OFFLINE VIEW: No stats, just a message
            const Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: Colors.white24,
            ),
            const SizedBox(height: 12),
            const Text(
              "Station is currently offline",
              // "No live stream available at the moment.",
              style: TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => prov.checkStreamAvailability(),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text("Refresh Status"),
            ),
          ] else ...[
            // LIVE VIEW: Show Title and Stats
            Row(
              children: [
                // Visual Indicator
                _buildLivePulse(isPlaying, mint),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // DYNAMIC STATUS TEXT
                      Text(
                        "LIVE STREAM",
                        style: TextStyle(
                          color: isPlaying ? mint : Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // DYNAMIC TITLE FROM ICECAST
                      Text(
                        prov.streamTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isLoading
                            ? "Connecting..."
                            : (isPlaying ? "Now Playing" : "Start Playing"),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // PLAY / LOADING / PAUSE BUTTON
                GestureDetector(
                  onTap:
                      isLoading
                          ? null
                          : () =>
                              prov.togglePlay(), // Disable tap while loading
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isPlaying ? Colors.transparent : mint,
                      shape: BoxShape.circle,
                      border: Border.all(color: mint, width: 2),
                    ),
                    // if loading, show CircularProgressIndicator
                    // else show play/pause icon
                    child:
                        isLoading
                            ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: mint,
                              ),
                            )
                            : Icon(
                              isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: isPlaying ? mint : const Color(0xFF181C27),
                              size: 32,
                            ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // Sub-widget for the "Pulse" animation effect
  Widget _buildLivePulse(bool isPlaying, Color color) {
    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      // Use music visualizer when playing, else static icon
      // Icons.graphic_eq_rounded
      child:
          isPlaying
              ? MiniMusicVisualizer(
                color: color,
                width: 4,
                height: 15,
                animate: true,
              )
              : Icon(Icons.radio_rounded, color: color, size: 28),
    );
  }

  // MAIN PLAYER DASHBOARD

  // // STAT CHIPS (Listeners & Comments Toggle)
  // Widget _buildStatChip(
  //   IconData icon,
  //   String count,
  //   String label, {
  //   VoidCallback? onTap,
  //   bool isActive = false,
  //   Color? activeColor,
  // }) {
  //   return Expanded(
  //     child: InkWell(
  //       onTap: onTap,
  //       borderRadius: BorderRadius.circular(16),
  //       child: Container(
  //         padding: const EdgeInsets.symmetric(vertical: 12),
  //         decoration: BoxDecoration(
  //           color:
  //               isActive
  //                   ? activeColor?.withOpacity(0.1)
  //                   : Colors.white.withOpacity(0.03),
  //           borderRadius: BorderRadius.circular(16),
  //           border: Border.all(
  //             color: isActive ? activeColor! : Colors.white.withOpacity(0.05),
  //           ),
  //         ),
  //         child: Column(
  //           children: [
  //             Icon(
  //               icon,
  //               size: 20,
  //               color: isActive ? activeColor : Colors.white38,
  //             ),
  //             const SizedBox(height: 4),
  //             Text(
  //               count,
  //               style: const TextStyle(
  //                 fontWeight: FontWeight.bold,
  //                 fontSize: 16,
  //               ),
  //             ),
  //             Text(
  //               label,
  //               style: const TextStyle(color: Colors.white38, fontSize: 10),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
