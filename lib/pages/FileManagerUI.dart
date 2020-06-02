import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sms_download/appcore/CommonFunctions.dart';
import 'package:sms_download/appcore/UITheme.dart';
import 'package:sms_download/logic/FileIOLib.dart';
import 'package:sms_download/logic/ShareLib.dart';

class FileManagerUI extends StatefulWidget {
  FileManagerUI({Key key}) : super(key: key);

  _FileManagerUIState createState() => _FileManagerUIState();
}

enum MenuChoices { open, share, delete }

class _FileManagerUIState extends State<FileManagerUI> {
  FileIOLib _fileIOLib = new FileIOLib();

  List<FileSystemEntity> _fileList;
  bool _loadingFiles = true;
  File _selectedFile;
  int _selectedIndex;

  MenuChoices _menuSelection;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  /// Load all files from application folder
  Future<bool> _loadFiles() async {
    _loadingFiles = true;

    _fileList = await _fileIOLib.getDownloadedFilesList();

    _loadingFiles = false;

    this.setState(() {});

    if (_fileList == null || _fileList.length == 0)
      return false;
    else
      return true;
  }

  /// Handles Menu selections
  Future _menuItemSelected() async {
    if (_selectedIndex != null && _selectedIndex > _fileList.length - 1) {
      await CommonFunctions.getInformationDialogResult(
          context, "You must select a file first");
      return;
    }

    if (_selectedFile == null || _selectedIndex == null) {
      await CommonFunctions.getInformationDialogResult(
          context, "You must select a file first");
      return;
    }

    bool result;
    if (_menuSelection == MenuChoices.open) {
      result = await CommonFunctions.getConfirmationDialogResult(
          context, "Are you sure you want to open this file?");
      if (result != null && result) _openFile(_selectedFile);
    }
    if (_menuSelection == MenuChoices.share) {
      result = await CommonFunctions.getConfirmationDialogResult(
          context, "Are you sure you want to share this file?");
      if (result != null && result) _shareFile(_selectedFile);
    } else if (_menuSelection == MenuChoices.delete) {
      result = await CommonFunctions.getConfirmationDialogResult(
          context, "Are you sure you want to delete this file?");
      if (result != null && result) _deleteFile(_selectedFile);
    }
  }

  /// Handles Open File menu selection
  void _openFile(File file) {
    try {
      _fileIOLib.openFile(file.path);
    } catch (e) {
      CommonFunctions.getInformationDialogResult(context, e.toString());
    }
  }

  /// Handles Share File menu selection
  void _shareFile(File file) {
    ShareLib shareLib = ShareLib();
    try {
      shareLib.shareMessagesAsFile(file);
    } catch (e) {
      CommonFunctions.getInformationDialogResult(context, e.toString());
    }
  }

  /// Handles Delete File menu selection
  void _deleteFile(File file) async {
    try {
      await _fileIOLib.deleteFile(file);
      _selectedIndex = null;
      _loadFiles();
    } catch (e) {
      CommonFunctions.getInformationDialogResult(context, e.toString());
    }
  }

  /// Handles a file tap/selection
  void _fileSelected(File file, int currFileIndex) {
    _selectedIndex = currFileIndex;
    _selectedFile = file;

    setState(() {});
  }

  /// BUILD
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // HEADER
        appBar: AppBar(
          title: ListTile(
              contentPadding: EdgeInsets.all(0.0),

              // APP TITLE
              title: Padding(
                padding: const EdgeInsets.only(bottom: 0.0),
                child: Text("Downloaded Files...",
                    style: TextStyle(
                        color: UITheme.hdrTxtColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0)),
              ),

              // SUBTITLE
              subtitle: Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  "Select file",
                  style: TextStyle(color: UITheme.hdrTxtColor, fontSize: 12.0),
                ),
              ),

              // MENU ICON
              trailing: InkWell(
                child: PopupMenuButton<MenuChoices>(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.white,
                  ),
                  onSelected: (MenuChoices result) {
                    setState(() {
                      _menuSelection = result;
                      _menuItemSelected();
                    });
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<MenuChoices>>[
                    const PopupMenuItem<MenuChoices>(
                      value: MenuChoices.open,
                      child: Text('Open File'),
                    ),
                    const PopupMenuItem<MenuChoices>(
                      value: MenuChoices.share,
                      child: Text('Share File...'),
                    ),
                    const PopupMenuItem<MenuChoices>(
                      value: MenuChoices.delete,
                      child: Text('Delete File'),
                    ),
                  ],
                ),
              )),
          backgroundColor: UITheme.hdrBgColor,
        ),

        // BODY
        body: (_loadingFiles)
            ? Center(child: UITheme.getLoadingWidget())
            : Column(
                children: <Widget>[
                  // LIST VIEW: THREADS LIST
                  Expanded(
                    child: Scrollbar(
                      child: ListView.builder(
                          itemCount: _fileList == null ? 0 : _fileList.length,
                          itemBuilder: (BuildContext context, int index) {
                            debugPrint("INDEX: " + index.toString());
                            // LOGIC FOR FILTERING
                            return (Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: Container(
                                  // HIGHLIGHT SELECTION
                                  decoration: BoxDecoration(
                                      color: (index == _selectedIndex)
                                          ? UITheme.highlightBgColor
                                          : UITheme.hdrTxtColor,
                                      border: Border.all(
                                          color: UITheme.bodyTxt2Color,
                                          width: 0.25)),
                                  child: ListTile(
                                    // TITLE
                                    title: Text(
                                        _fileIOLib
                                            .getFileName(_fileList[index]),
                                        style: TextStyle(fontSize: 14)),

                                    // SUBTITLE
                                    subtitle: Text(
                                        _fileIOLib
                                            .getFileDate(_fileList[index]),
                                        style: TextStyle(
                                            color: UITheme.bodyTxt2Color,
                                            fontSize: 13.0)),

                                    // TRAILING
                                    trailing: Text(
                                        _fileIOLib
                                            .getFileSize(_fileList[index]),
                                        style: TextStyle(fontSize: 11.0)),

                                    // ON TAP
                                    onTap: () =>
                                        _fileSelected(_fileList[index], index),
                                  ),
                                )));
                          }),
                    ),
                  ),
                ],
              ),

        // FOOTER
        // bottomNavigationBar: new Container(
        //     color: UITheme.hdrBgColor,
        //     height: 50.0,
        //     child: ListTile(
        //       // TRAILING
        //       trailing: Text(
        //           "Files: " +
        //               (_fileList == null ? "0" : _fileList.length.toString()) +
        //               ", Folder Size: " +
        //               _fileIOLib.getSizeOfAllFiles(_fileList),
        //           style: TextStyle(color: UITheme.hdrTxtColor, fontSize: 11.0)),
        //     )),

        bottomNavigationBar: new Container(
            color: UITheme.hdrBgColor,
            height: 100.0,
            child: Column(
              children: <Widget>[
                Container(
                  height: 50.0,
                  color: UITheme.hdrBgColor,
                  child: ListTile(
                    // TRAILING
                    trailing: Text(
                        "Files: " +
                            (_fileList == null
                                ? "0"
                                : _fileList.length.toString()) +
                            ", Folder Size: " +
                            _fileIOLib.getSizeOfAllFiles(_fileList),
                        style: TextStyle(
                            color: UITheme.hdrTxtColor, fontSize: 11.0)),
                  ),
                ),
                Container(height: 50.0, color: Colors.black, child: ListTile())
              ],
            )));
  }
}
