import 'package:flutter/cupertino.dart';
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
        16,
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
          // const SizedBox(height: 24),

          // COPYRIGHT AND DEVELOPER SECTION
          const SizedBox(height: 8),

          // Developer Name & Studio
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Brief about app
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "© 2025 SPS STUDIO",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      // color: theme.colorScheme.primary, // Mint color
                      color: Colors.white.withOpacity(0.4),
                      // letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "(Simon Peters)",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.4),
                      // letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),

              // Tagline
              Text(
                "Crafting digital experiences through web and mobile apps.",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.4),
                  fontStyle: FontStyle.italic,
                ),
              ),

              // copyright
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  "All Rights Reserved. LiveCast is an on-demand premium audio streaming platform.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
