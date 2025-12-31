import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'ui/download_page.dart';
import 'ui/home_page.dart';
import 'utils/app_theme.dart';
import 'providers/app_provider.dart';
import 'package:just_audio_background/just_audio_background.dart';

Future<void> main() async {
  // WidgetsFlutterBinding.ensureInitialized();

  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Initialize Background Audio Service
  await JustAudioBackground.init(
    androidNotificationChannelId:
        'com.thesps.livecast.channel.audio', // UNIQUE TO YOUR APP IDENTIFIER AND NOT BE CHANGED
    androidNotificationChannelName: 'Livecast Audio Playback',
    androidNotificationIcon: 'mipmap/launcher_icon',
    androidNotificationOngoing: true,
  );

  // Initialize the splash screen
  // Keep the splash screen until your initialization logic (like Supabase/Auth) is done
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // In your HomePage or whenever initialization is done:
  // FlutterNativeSplash.remove();

  await Supabase.initialize(
    url: 'https://kyphaztggqrlfmciezog.supabase.co',
    anonKey: 'sb_publishable_-bhzC-NOnXMXaZeXQMr5Qg_33GNlFWI',
  );

  runApp(
    ChangeNotifierProvider(create: (_) => AppProvider(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      // home: const HomePage(),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/download': (context) => const DownloadPage(),
      },
    );
  }
}
