// Android APK Download Page
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DownloadPage extends StatelessWidget {
  const DownloadPage({super.key});

  // APK DOWNLOAD Link
  final String apkUrl =
      "https://firebasestorage.googleapis.com/.../app-release.apk";

  Future<void> _downloadApk() async {
    if (!await launchUrl(
      Uri.parse(apkUrl),
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('An error occurred downloading APK. Try again later.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mint = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFF181C27),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. App Icon & Header
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    image: const DecorationImage(
                      image: AssetImage("assets/images/livecast-logo.png"),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "SPS LiveCast",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Version 1.0.2 • Last updated: Dec 25, 2025",
                  style: TextStyle(color: Colors.white38, fontSize: 14),
                ),

                const SizedBox(height: 32),

                // 2. Download Button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: _downloadApk,
                    icon: const Icon(Icons.android_rounded),
                    label: const Text(
                      "DOWNLOAD ANDROID APK",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mint,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // 3. Installation Guide
                _buildInfoSection(
                  context,
                  title: "Installation Guide",
                  icon: Icons.security_rounded,
                  content:
                      "1. Download the APK file.\n 2. Open your File Manager and locate the apk file.\n 3. Tap to install. If prompted, enable 'Install from Unknown Sources' in your Android settings.",
                ),

                const SizedBox(height: 20),

                _buildInfoSection(
                  context,
                  title: "Why APK?",
                  icon: Icons.info_outline_rounded,
                  content:
                      "Installing via APK allows you to get the Android app and latest features directly from our platform before they hit the app stores.",
                ),

                // #################################
                // #################################
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "More from SPS Studio",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),

                // Horizontal or Grid list of other apps
                Column(
                  children: [
                    _buildOtherAppTile(
                      context,
                      name: "SPS STUDIO",
                      desc: "Explore custom software & web solutions.",
                      icon: Icons.language_rounded,
                      url: "https://thesps.online",
                    ),
                    const SizedBox(height: 12),
                    _buildOtherAppTile(
                      context,
                      name: "SPS Inventory", // Example app name
                      desc: "Smart business management tools.",
                      icon: Icons.inventory_2_outlined,
                      url: "https://thesps.online",
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Link to "All Apps" external page
                TextButton.icon(
                  onPressed:
                      () => launchUrl(
                        Uri.parse("https://thesps.online"),
                        mode: LaunchMode.externalApplication,
                      ),
                  icon: const Icon(Icons.rocket_launch_outlined, size: 18),
                  label: const Text("VIEW ALL APPS & SERVICES"),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              height: 1.6,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for other app entries
  Widget _buildOtherAppTile(
    BuildContext context, {
    required String name,
    required String desc,
    required IconData icon,
    required String url,
  }) {
    return InkWell(
      onTap:
          () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white38, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    desc,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.launch_rounded, color: Colors.white24),
          ],
        ),
      ),
    );
  }

  // end of class
}
