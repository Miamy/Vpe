import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'file_view_state.dart';

class FileViewCubit extends Cubit<FileViewState> {
  FileViewCubit()
      : super(FileViewState(
          files: [],
          current: '',
          parent: 'C:',
        ));

  void setCurrent(String value) {
    if (!value.contains(Platform.pathSeparator)) {
      value = state.parent + Platform.pathSeparator + value;
    }
    emit(state.copyWith(current: value));
  }

  Future<void> setParent(String value) async {
    if (await _listOfFiles(value)) {
      emit(state.copyWith(parent: value));
    }
  }

  void setFiles(List<String> value) {
    emit(state.copyWith(files: value));
  }

  Future<bool> _listOfFiles(String parent) async {
    try {
      final entries = Directory(parent).listSync();

      entries.sort(
        (a, b) {
          if (a is Directory && b is Directory || a is File && b is File) {
            return a.path.compareTo(b.path);
          }
          if (a is Directory && b is File) {
            return -1;
          }
          return 1;
        },
      );

      final files = <String>[];
      files.clear();
      files.add('..');
      for (final entry in entries) {
        final path = entry.path;
        final file =
            path.substring(path.lastIndexOf(Platform.pathSeparator) + 1);
        files.add(file);
      }
      setFiles(files);
      return true;
    } catch (e) {
      return false;
    }
  }

  void previous() {
    if (state.files.isEmpty) {
      return;
    }
    final index = _getIndex();
    if (index == -1) {
      return;
    }
    if (index < 2) {
      setCurrent(state.files[state.files.length - 1]);
    } else {
      setCurrent(state.files[index - 1]);
    }
  }

  void next() {
    if (state.files.isEmpty) {
      return;
    }
    final index = _getIndex();
    if (index == -1) {
      return;
    }
    if (index == state.files.length - 1) {
      setCurrent(state.files[1]);
    } else {
      setCurrent(state.files[index + 1]);
    }
  }

  Future<void> delete() async {
    final index = _getIndex();
    if (index == -1) {
      return;
    }
    final file = File(state.current);
    await file.delete();
    await _listOfFiles(state.parent);
    if (state.files.isEmpty) {
      return;
    }
    if (index < state.files.length) {
      setCurrent(state.files[index]);
    } else {
      setCurrent(state.files[index - 1]);
    }
  }

  int _getIndex() => state.files.indexWhere((e) => state.current.contains(e));
}
