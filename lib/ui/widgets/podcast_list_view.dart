import 'package:flutter/material.dart';
import '../../services/podcast_service.dart';

// class PodcastListView extends StatelessWidget {
//   const PodcastListView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<PodcastEpisode>>(
//       future: PodcastService().fetchEpisodes(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const SliverToBoxAdapter(
//             child: Center(
//               child: Padding(
//                 padding: EdgeInsets.all(20.0),
//                 child: CircularProgressIndicator(),
//               ),
//             ),
//           );
//         }

//         if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           return const SliverToBoxAdapter(child: Text("No podcasts found"));
//         }

//         final episodes = snapshot.data!;

//         return SliverList(
//           delegate: SliverChildBuilderDelegate((context, index) {
//             final ep = episodes[index];
//             return Card(
//               margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: ListTile(
//                 leading: ClipRRect(
//                   borderRadius: BorderRadius.circular(4),
//                   child: Image.network(
//                     ep.imageUrl,
//                     width: 50,
//                     height: 50,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 title: Text(
//                   ep.title,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 subtitle: Text(
//                   ep.pubDate,
//                   style: const TextStyle(fontSize: 12),
//                 ),
//                 trailing: const Icon(Icons.play_circle_outline),
//                 onTap: () {
//                   // logic to play podcast instead of live stream
//                 },
//               ),
//             );
//           }, childCount: episodes.length),
//         );
//       },
//     );
//   }
// }

class PodcastListView extends StatelessWidget {
  const PodcastListView({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PodcastEpisode>>(
      future: PodcastService().fetchEpisodes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      "Error loading podcasts. Check internet connection and try again.",
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(onPressed: () {}, child: Text("Reload")),
                  ],
                ),
              ),
            ),
          );
        }

        if (snapshot.data!.isEmpty) {
          return SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(40),
              child: const Column(
                children: [
                  Icon(Icons.library_music, size: 40, color: Colors.white12),
                  SizedBox(height: 10),
                  Text(
                    "No podcasts available for this channel.",
                    style: TextStyle(color: Colors.white30),
                  ),
                ],
              ),
            ),
          );
        }

        final episodes = snapshot.data!;
        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final ep = episodes[index];
            return ListTile(
              leading: Image.network(
                ep.imageUrl,
                width: 50,
                errorBuilder: (c, e, s) => const Icon(Icons.mic),
              ),
              title: Text(ep.title),
              subtitle: Text(ep.pubDate, style: const TextStyle(fontSize: 11)),
              trailing: const Icon(Icons.play_arrow),
              onTap: () {
                // Logic to switch AudioService from Live Stream to this URL
              },
            );
          }, childCount: episodes.length),
        );
      },
    );
  }
}
