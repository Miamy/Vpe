import 'package:fluent_ui/fluent_ui.dart';
import 'package:media_kit/media_kit.dart';
import 'package:vpe/src/my_app.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await WindowManager.instance.ensureInitialized();
  windowManager
      .waitUntilReadyToShow(
    const WindowOptions(
      skipTaskbar: false,
      minimumSize: Size(500, 600),
      center: true,
      fullScreen: false,
      title: "Video Player Extended",
      titleBarStyle: TitleBarStyle.hidden,
      windowButtonVisibility: false,
    ),
  )
      .then(
    (_) async {
      await windowManager.maximize();
    },
  );

  MediaKit.ensureInitialized();

  runApp(const MyApp());
}
