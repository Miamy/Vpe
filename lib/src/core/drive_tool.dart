import 'dart:convert';
import 'dart:io';

class DriveTool {
  /// Utility Function That Creates The List of Drives
  static Future<void> _createDriveList() async {
    // CMD command variables
    var cmd = "cmd";
    var directoryPath = Directory.current.path;
    var outputFilePath = '$directoryPath\\directory.txt';

    // CMD command arguments
    List<String> args = [
      '/c',
      'wmic',
      'logicaldisk',
      'get',
      'caption',
      '>',
      outputFilePath
    ];

    await Process.run(cmd, args);
  }

  /// This Function Will Return The List of Available Drives On The Windows Device
  static Future<List<String>> getDriveList() async {
    // After creating drive list
    return await _createDriveList().then((value) {
      List<String> driveList;
      File driveFile = File("directory.txt");

      // Read drive data
      String driveString = driveFile
          .readAsBytesSync()
          .buffer
          .asUint16List()
          .map((codeUnit) => String.fromCharCode(codeUnit))
          .join();

      // Cleanup and preprocess the drive data
      driveList = const LineSplitter()
          .convert(driveString.toString().trim().replaceAll("       ", ""));

      // Filter out the hard drives
      List<String> filteredList = [];
      for (var element in driveList) {
        if (element.length <= 2) {
          filteredList.add(element);
        }
      }

      // Delete the file that contains drive data
      driveFile.deleteSync();

      // Return filtered drive list
      return filteredList;
    });
  }
}
