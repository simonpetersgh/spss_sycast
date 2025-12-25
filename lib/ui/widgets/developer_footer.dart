import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MyDeveloperFooter extends StatelessWidget {
  const MyDeveloperFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        40,
        16,
        60,
      ), // Extra bottom padding for safe area
      child: Column(
        children: [
          // Subtle divider with gradient
          Container(
            height: 1,
            width: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  theme.colorScheme.secondary,
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // DEVELOPED BY TEXT
          Text(
            "Developed by",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.4),
            ),
          ),

          const SizedBox(height: 8),

          // Logo with a glowing border
          // Container(
          //   padding: const EdgeInsets.all(3), // Border thickness
          //   decoration: BoxDecoration(
          //     // shape: BoxShape.circle,
          //     gradient: LinearGradient(
          //       colors: [
          //         theme.colorScheme.primary,
          //         theme.colorScheme.secondary,
          //       ],
          //     ),
          //   ),
          //   // child: CircleAvatar(
          //   //   radius: 35,
          //   //   backgroundColor: theme.scaffoldBackgroundColor,
          //   //   backgroundImage: const NetworkImage(
          //   //     "https://firebasestorage.googleapis.com/v0/b/sesa-studio.firebasestorage.app/o/livecast%2FSPS%20Developer%20Logo.png?alt=media&token=79bee5ca-a5fc-4bd6-9871-626943bacb56",
          //   //   ),
          //   // ),
          //   child: Image.network(
          //     "https://firebasestorage.googleapis.com/v0/b/sesa-studio.firebasestorage.app/o/livecast%2FSPS%20Developer%20Logo.png?alt=media&token=79bee5ca-a5fc-4bd6-9871-626943bacb56",
          //     width: 40,
          //     height: 40,
          //   ),
          // ),

          // Developer Name & Studio
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "SPS STUDIO",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.primary, // Mint color
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                "(Simon Peters)",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Tagline
          Text(
            "Crafting digital experiences through web and mobile apps.",
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.4),
              fontStyle: FontStyle.italic,
            ),
          ),

          const SizedBox(height: 12),

          // // Social / Web Button (Optional)
          // OutlinedButton(
          //   onPressed: () {
          //     // Add link to your portfolio or website
          //     // launch portfolio url (Uri.parse("https://thesps.online"));
          //     Uri url = Uri.parse("https://thesps.online");
          //     launchUrl(url);
          //   },
          //   style: OutlinedButton.styleFrom(
          //     side: BorderSide(color: Colors.white.withOpacity(0.1)),
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(20),
          //     ),
          //   ),
          //   child: const Text(
          //     "Visit Studio",
          //     style: TextStyle(fontSize: 10, color: Colors.white70),
          //   ),
          // ),
        ],
      ),
    );
  }
}
