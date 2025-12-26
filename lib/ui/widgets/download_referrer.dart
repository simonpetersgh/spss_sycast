// // ANDROID APK DOWNLOAD REFERRER WIDGET
// import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;

// class AppDownloadReferrerCard extends StatelessWidget {
//   const AppDownloadReferrerCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Only render the card if it's Web.
//     // Optional: add '&& defaultTargetPlatform == TargetPlatform.android'
//     // to specifically target Android browsers.
//     // if (!kIsWeb) return const SliverToBoxAdapter(child: SizedBox.shrink());

//     final mint = Theme.of(context).colorScheme.primary;
//     final purple = Theme.of(context).colorScheme.secondary;

//     return SliverToBoxAdapter(
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//         padding: const EdgeInsets.all(2), // For gradient border
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(24),
//           gradient: LinearGradient(
//             colors: [mint.withOpacity(0.5), purple.withOpacity(0.5)],
//           ),
//         ),
//         child: Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: const Color(0xFF1E2431),
//             borderRadius: BorderRadius.circular(22),
//           ),
//           child: Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       "Get the Android App",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     const Text(
//                       "Experience seamless streaming with the dedicated android app.",
//                       style: TextStyle(color: Colors.white54, fontSize: 12),
//                     ),
//                     const SizedBox(height: 12),
//                     TextButton(
//                       onPressed:
//                           () => Navigator.pushNamed(context, '/download'),
//                       style: TextButton.styleFrom(padding: EdgeInsets.zero),
//                       child: Row(
//                         children: [
//                           Text(
//                             "Go to Download",
//                             style: TextStyle(
//                               color: mint,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           Icon(
//                             Icons.arrow_forward_rounded,
//                             size: 16,
//                             color: mint,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Icon(Icons.android_rounded, size: 60, color: mint),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDownloadReferrerCard extends StatelessWidget {
  const AppDownloadReferrerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mint = theme.colorScheme.primary;
    final purple = theme.colorScheme.secondary;

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            // TOP SECTION: Internal Download (Focus for Web)
            // if (kIsWeb)
            _buildActionTile(
              context,
              title: "Get the Android App",
              subtitle:
                  "Download the SPS LiveCast APK for a native experience.",
              icon: Icons.android_rounded,
              iconColor: mint,
              buttonText: "Go to Download",
              onTap: () => Navigator.pushNamed(context, '/download'),
              isPrimary: true,
            ),

            // Divider if on Web (to separate the two sections)
            if (kIsWeb)
              Divider(
                height: 1,
                color: Colors.white.withOpacity(0.05),
                indent: 20,
                endIndent: 20,
              ),

            // BOTTOM SECTION: External Studio Portfolio (For All Platforms)
            _buildActionTile(
              context,
              title: "Explore Other Apps",
              subtitle:
                  "Discover more high-quality apps and digital solutions.",
              icon: Icons.grid_view_rounded,
              iconColor: theme.colorScheme.primary,
              buttonText: "Visit Portfolio",
              onTap:
                  () => launchUrl(
                    Uri.parse("https://thesps.online/projects"),
                    mode: LaunchMode.externalApplication,
                  ),
              isPrimary: !kIsWeb, // Make this primary if we aren't on Web
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required String buttonText,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    final mint = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
                const SizedBox(height: 12),

                // Adaptive Button
                InkWell(
                  onTap: onTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        buttonText,
                        style: TextStyle(
                          color: isPrimary ? mint : Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: isPrimary ? mint : Colors.white70,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
