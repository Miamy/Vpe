import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vpe/src/bloc/file_view/file_view_cubit.dart';
import 'package:vpe/src/views/main_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FileViewCubit(),
      child: FluentApp(
        supportedLocales: const [Locale('ru')],
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        darkTheme: FluentThemeData(
          brightness: Brightness.dark,
          visualDensity: VisualDensity.standard,
          focusTheme: FocusThemeData(
            glowFactor: is10footScreen(context) ? 2.0 : 0.0,
          ),
        ),
        theme: FluentThemeData(
          visualDensity: VisualDensity.standard,
          focusTheme: FocusThemeData(
            glowFactor: is10footScreen(context) ? 2.0 : 0.0,
          ),
        ),
        home: const MainPage(),
      ),
    );
  }
}
