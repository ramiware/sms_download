import 'dart:io';
import 'dart:async';

import 'package:date_format/date_format.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class FileIOLib {
  /// Returns the file name
  String getFileName(File file) {
    return file.path.split('/').last;
  }

  /// Returns the file last modified date
  String getFileDate(File file) {
    return formatDate(file.lastModifiedSync(),
        [yyyy, '-', mm, '-', dd, ' ', hh, ':', nn, ':', ss, ' ', am]);
  }

  /// Returns the file size
  String getFileSize(File file) {
    return filesize(file.lengthSync());
  }

  /// Returns the total size of all files
  String getSizeOfAllFiles(List<FileSystemEntity> fileList) {
    if (fileList==null)
    return "0";
    
    int totalSize = 0;
    for (File currFile in fileList) totalSize += currFile.lengthSync();

    return filesize(totalSize);
  }

  /// Opens the file using system apps as options
  void openFile(String filePath){
    OpenFile.open(filePath);
  }

  /// Deletes the file
  Future<void> deleteFile(File file) async{
    await file.delete();
    // file.deleteSync();
  }

  /// Returns the external default path
  Future<String> get _externalPath async {
    Directory dir = await getExternalStorageDirectory();
    var ramiwareDir =
        await new Directory('${dir.path}').create(recursive: true);
    // await new Directory('${dir.path}/ramiware').create(recursive: true);
    return ramiwareDir.path;
  }

  /// Returns a File with path using the filename provided as part of
  /// the filename
  Future<File> _getExternalFile(String filename, String ext) async {
    final path = await _externalPath;
    final filenameWExt = filename + "." + ext;

    return File('$path/$filenameWExt');
  }

  /// Writes a String to the external file
  Future<File> writeStringToExternalFile(
      String valueToWrite, String filename, String ext) async {
    final file = await _getExternalFile(filename, ext);
    // debugPrint("Writing to External file: " + file.toString());
    // Write the file.
    return file.writeAsString("$valueToWrite");
  }

  /// Writes the htmlContent to an external pdf file
  Future<File> writePDFToExternalFile(
      String htmlContent, String filename) async {
    final path = await _externalPath;
    var generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
        htmlContent, path, filename);

    return generatedPdfFile;
  }

  /// [NOT USED] Writes bytes to the external file
  Future<File> writeBytesToExternalFile(
      List<int> bytesToWrite, String filename, String ext) async {
    final file = await _getExternalFile(filename, ext);
    // debugPrint("Writing to External file: " + file.toString());
    // Write the file.
    return file.writeAsBytes(bytesToWrite);
  }

  /// Returns all downloaded files in a List<FileSystemEntity>
  Future<List<FileSystemEntity>> getDownloadedFilesList() async {
    var root = await getExternalStorageDirectory();
    List<FileSystemEntity> fileList =
        await FileManager(root: root).walk().toList();

    return fileList;
  }

  /// Returns the default app local path for file writing
  /*
  Future<String> get _localPath async {
    Directory appDocDirectory = await getApplicationDocumentsDirectory();
    return appDocDirectory.path;
  }
*/
  /// Returns a file object using the default path and a hardcode filename
  /*
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/contact_messages.txt');
  }
*/
  /// Writes to the local file
  /*
  Future<File> writeToLocalFile(String valueToWrite) async {
    final file = await _localFile;
    // debugPrint("Writing to local file: " + file.toString());
    // Write the file.
    return file.writeAsString("$valueToWrite");
  }
*/
  /// File read
  /*
  Future<String> readFile() async {
    try {
      final file = await _localFile;

      // Read the file.
      String contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If encountering an error, return 0.
      return e.toString();
    }
  }
*/
}
