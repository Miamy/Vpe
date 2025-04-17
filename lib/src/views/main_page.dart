import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vpe/src/bloc/file_view/file_view_cubit.dart';

import 'package:window_manager/window_manager.dart';

import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'widgets/confirmation_dialog.dart';
import 'widgets/file_system_view.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  static const vpe = "Video Player Extended";

  late final player = Player();
  late final controller = VideoController(player);
  bool startedPlaying = false;

  var filename = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Future<bool> openAndPlay() async {
    if (filename.isEmpty) {
      return false;
    }
    final file = File(filename);
    if (!await file.exists()) {
      return false;
    }
    await player.stop();
    await player.open(
      Media(
        'file:///$filename',
        //start: const Duration(minutes: 1),
      ),
      play: false,
    );
    //await player.setVolume(20);
    await player.play();
    startedPlaying = true;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FileViewCubit, FileViewState>(
      listenWhen: (previous, current) => previous.current != current.current,
      listener: (context, state) async {
        filename = state.current;
        await openAndPlay();
      },
      builder: (context, state) {
        return NavigationView(
          appBar: NavigationAppBar(
            automaticallyImplyLeading: false,
            actions: !kIsWeb ? const WindowButtons() : null,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const DragToMoveArea(child: Icon(FluentIcons.video)),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: DragToMoveArea(
                    child: Align(
                      alignment: AlignmentDirectional.center,
                      child: Text(
                        state.current.isEmpty ? vpe : '$vpe - ${state.current}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          content: ScaffoldPage(
            content: Row(
              children: [
                Column(
                  children: [
                    SizedBox(
                      width: 400,
                      child: FileSystemView(
                        onFileSelected: (filename) async {},
                      ),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: IconButton(
                              icon: const Icon(FluentIcons.previous),
                              onPressed: () =>
                                  context.read<FileViewCubit>().previous()),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: IconButton(
                            icon: const Icon(FluentIcons.stop),
                            onPressed: () async => await player.stop(),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: IconButton(
                            icon: player.state.playing
                                ? const Icon(FluentIcons.pause)
                                : const Icon(FluentIcons.play),
                            onPressed: () async => await player.playOrPause(),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: IconButton(
                              icon: const Icon(FluentIcons.next),
                              onPressed: () =>
                                  context.read<FileViewCubit>().next()),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: IconButton(
                            icon: const Icon(FluentIcons.delete),
                            onPressed: () async {
                              await showConfirmationDialog(
                                context,
                                content: 'Удалить?',
                                onConfirmedAction: () async {
                                  await player.stop();
                                  if (context.mounted) {
                                    await context
                                        .read<FileViewCubit>()
                                        .delete();
                                  }
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                },
                                onDeclinedAction: () {
                                  Navigator.of(context).pop();
                                },
                                noButtonIsFilled: true,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  child: FutureBuilder<bool>(
                    future: openAndPlay(),
                    builder:
                        (BuildContext context, AsyncSnapshot<bool> snapshot) {
                      if (snapshot.data ?? false) {
                        return AspectRatio(
                          aspectRatio: 1.4,
                          child: Video(
                            controller: controller,
                            filterQuality: FilterQuality.high,
                            controls: MaterialDesktopVideoControls,
                          ),
                        );
                      } else {
                        return const Align(
                            alignment: Alignment.center,
                            child: Text('waiting for video to load'));
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CustomAppBar {
  NavigationAppBar defaultAppBar({
    bool automaticallyImplyLeading = true,
  }) {
    return NavigationAppBar(
        automaticallyImplyLeading: automaticallyImplyLeading,
        actions: !kIsWeb ? const WindowButtons() : null,
        title: const Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text("Video Player Extended"),
        ));
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final FluentThemeData theme = FluentTheme.of(context);

    return SizedBox(
      width: 138,
      height: 50,
      child: WindowCaption(
        brightness: theme.brightness,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
