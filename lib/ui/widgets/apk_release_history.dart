import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';

// ANDROID APK RELEASE HISTORY WIDGET
// Archive of previous app versions for download
class ApkReleaseHistoryWidget extends StatelessWidget {
  const ApkReleaseHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<AppProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Android Apk Release History",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ListView.builder(
          shrinkWrap: true, // Necessary inside a ScrollView
          physics: const NeverScrollableScrollPhysics(),
          itemCount: prov.apkReleaseHistory.length,
          itemBuilder: (context, index) {
            final ver = prov.apkReleaseHistory[index];
            bool isCurrent = index == 0;

            return ListTile(
              leading: Icon(
                Icons.history,
                color: isCurrent ? Theme.of(context).primaryColor : Colors.grey,
              ),
              title: Text("Version ${ver['version_name']}"),
              subtitle: Text(
                ver['release_notes'] ?? "Bug fixes and improvements",
              ),
              trailing: ElevatedButton(
                onPressed: () => prov.downloadApk(ver['apk_url']),
                child: const Text("Get APK"),
              ),
            );
          },
        ),
      ],
    );
  }
}
