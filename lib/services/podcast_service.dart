// THIRD PARTY PODCAST SERVICE
import 'package:http/http.dart' as http;
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

// import 'package:webfeed_revived/webfeed_revived.dart';

// class PodcastService {
//   // Replace with your 3rd party RSS link
//   final String rssUrl = "https://feeds.buzzsprout.com/YOUR_ID.rss";

//   Future<RssFeed> fetchPodcasts() async {
//     final response = await http.get(Uri.parse(rssUrl));
//     return RssFeed.parse(response.body);
//   }
// }


class PodcastEpisode {
  final String title;
  final String description;
  final String pubDate;
  final String audioUrl;
  final String imageUrl;

  PodcastEpisode({
    required this.title,
    required this.description,
    required this.pubDate,
    required this.audioUrl,
    required this.imageUrl,
  });
}

class PodcastService {
  final String rssUrl = "https://media.rss.com/spss-studio-and-lifestyle/feed.xml"; // e.g., Spotify/Buzzsprout RSS

  Future<List<PodcastEpisode>> fetchEpisodes() async {
    final response = await http.get(Uri.parse(rssUrl));
    if (response.statusCode == 200) {
      final document = XmlDocument.parse(response.body);
      final items = document.findAllElements('item');

      return items.map((node) {
        return PodcastEpisode(
          title: node.findElements('title').first.innerText,
          description: node.findElements('description').first.innerText,
          pubDate: node.findElements('pubDate').first.innerText,
          audioUrl: node.findElements('enclosure').first.getAttribute('url') ?? '',
          imageUrl: node.findElements('itunes:image').first.getAttribute('href') ?? '',
        );
      }).toList();
    }
    return [];
  }
}