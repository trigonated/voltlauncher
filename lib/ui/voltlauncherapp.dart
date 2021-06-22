import 'package:flutter/material.dart';
import 'package:voltlauncher/main.dart';
import 'package:voltlauncher/ui/newprofile/newprofile_page.dart';
import 'package:voltlauncher/ui/profile/profile_page.dart';
import 'package:window_control/window_control.dart';
import 'package:window_control/window_frame.dart';

class VoltLauncherApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _VoltLauncherAppState();
}

class _VoltLauncherAppState extends State<VoltLauncherApp> {
  Future<bool>? loading;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback(
      (_) async {
        await repository.loadSettings(reloadIfLoaded: false);
        if ((appSettings.useCustomWindowFrame) && (WindowControl.isSupported)) {
          WindowControl.centerWindow();
          WindowControl.hideTitleBar();
        }
      },
    );

    loading = repository.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Volt Launcher',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.orange,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.orange,
        accentColor: Colors.orangeAccent,
        // Widgets
        elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(primary: Colors.grey[800], onPrimary: Colors.white)),
      ),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: WindowsFrame(
        active: WindowControl.isSupported,
        child: FutureBuilder<bool>(
          future: loading,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              // Loaded
              if (repository.currentProfile != null) {
                return ProfilePage();
              } else {
                return NewProfilePage(showOptions: false);
              }
            } else {
              // Loading
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
