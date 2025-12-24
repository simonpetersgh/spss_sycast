import 'package:flutter/material.dart';
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
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<AppProvider>(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Banner Area
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                prov.currentStreamTitle,
                style: const TextStyle(fontSize: 14),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: Colors.black87),
                  const Center(
                    child: Icon(
                      Icons.graphic_eq,
                      size: 100,
                      color: Colors.pink,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Player Controls & Listeners
          SliverToBoxAdapter(child: buildPlayer(prov)),
          // SliverToBoxAdapter(
          //   child: Column(
          //     children: [
          //       const SizedBox(height: 10),
          //       Row(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           const Icon(Icons.people, size: 16, color: Colors.green),
          //           const SizedBox(width: 5),
          //           Text("${prov.listeners} tuning in"),
          //         ],
          //       ),
          //       IconButton(
          //         iconSize: 80,
          //         icon: Icon(prov.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
          //         color: Colors.pink,
          //         onPressed: () => prov.togglePlay(),
          //       ),
          //     ],
          //   ),
          // ),

          // Live Chat Header
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Live Comments (Last Hour)",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // The Comment Stream
          const SliverToBoxAdapter(
            child: SizedBox(height: 250, child: CommentSection()),
          ),

          // Comment Input Field (Handles Anon or Auth)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: "Say something...",
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      if (_commentController.text.isNotEmpty) {
                        prov.sendComment(
                          _commentController.text,
                          "Anonymous User",
                        );
                        _commentController.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          // Podcast Section
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Catch up on Episodes",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),

          // The Dynamic Podcast List
          const PodcastListView(),

          const SliverToBoxAdapter(child: SizedBox(height: 50)),
        ],
      ),
    );
  }

  // Inside your SliverToBoxAdapter for Player Controls
  Widget buildPlayer(AppProvider prov) {
    if (prov.streamStatus == StreamStatus.checking) {
      return const CircularProgressIndicator();
    }

    if (prov.streamStatus == StreamStatus.offline) {
      return Column(
        children: [
          const Icon(Icons.signal_wifi_off, size: 50, color: Colors.grey),
          const SizedBox(height: 10),
          const Text(
            "No active streaming at the moment",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          TextButton(
            onPressed: () => prov.checkStreamAvailability(),
            child: const Text("Retry Connection"),
          ),
        ],
      );
    }

    return IconButton(
      iconSize: 80,
      icon: Icon(
        prov.audio.player.playing ? Icons.pause_circle : Icons.play_circle,
      ),
      color: Colors.pink,
      onPressed: () => prov.togglePlay(),
    );
  }
}
