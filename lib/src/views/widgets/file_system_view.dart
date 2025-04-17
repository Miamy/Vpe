import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vpe/src/bloc/file_view/file_view_cubit.dart';

import '../../core/drive_tool.dart';

class FileSystemView extends StatefulWidget {
  const FileSystemView({
    super.key,
    required this.onFileSelected,
  });

  final Function(String filename) onFileSelected;

  @override
  State<FileSystemView> createState() => _FileSystemViewState();
}

class _FileSystemViewState extends State<FileSystemView> {
  late FileViewCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<FileViewCubit>();
    _cubit.setParent('C:');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FileViewCubit, FileViewState>(
      bloc: _cubit,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FutureBuilder<List<String>>(
                future: DriveTool.getDriveList(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data == null) {
                    return Container(
                      child: Text('Ждем диски...'),
                    );
                  }
                  return Wrap(
                    children: [
                      for (final disk in snapshot.data!)
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Button(
                            onPressed: () async {
                              await _cubit.setParent(disk);
                            },
                            style: state.parent.startsWith(disk)
                                ? ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(
                                        Colors.blue.darker),
                                  )
                                : null,
                            child: Text(disk),
                          ),
                        )
                    ],
                  );
                }),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 10, 10),
              child: SizedBox(
                height: 740,
                child: Container(
                  child: ListView.builder(
                    itemCount: state.files.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
                        child: Button(
                          onPressed: () async {
                            if (state.files[index] == '..') {
                              await _cubit.setParent(
                                state.parent.substring(
                                    0,
                                    state.parent
                                        .lastIndexOf(Platform.pathSeparator)),
                              );

                              return;
                            }
                            final name = state.parent +
                                Platform.pathSeparator +
                                state.files[index];
                            final test = Directory(name);

                            if (await test.exists()) {
                              await _cubit.setParent(name);
                            } else {
                              _cubit.setCurrent(name);
                              widget.onFileSelected(name);
                            }
                          },
                          style: state.current.contains(state.files[index])
                              ? ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(
                                      Colors.blue.darker),
                                )
                              : null,
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(state.files[index])),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Text(state.parent),
          ],
        );
      },
    );
  }
}
