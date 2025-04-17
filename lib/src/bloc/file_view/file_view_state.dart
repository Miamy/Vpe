part of 'file_view_cubit.dart';

class FileViewState with EquatableMixin {
  FileViewState({
    required this.parent,
    required this.current,
    required this.files,
  });

  final String parent;
  final String current;
  final List<String> files;

  @override
  List<Object?> get props => [
        parent,
        current,
        files,
      ];

  FileViewState copyWith({
    String? parent,
    String? current,
    List<String>? files,
  }) =>
      FileViewState(
        parent: parent ?? this.parent,
        current: current ?? this.current,
        files: files ?? this.files,
      );
}
