import 'dart:io';
import 'dart:math';

import 'package:filesize/filesize.dart';
import 'package:sms_download/appcore/CommonFunctions.dart';
import 'package:sms_download/appcore/UITheme.dart';
import 'package:sms_download/logic/FileIOLib.dart';
import 'package:sms_download/logic/PDFLib.dart';
import 'package:sms_download/logic/SMSLib.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sms_download/logic/ShareLib.dart';
import 'package:sms_download/models/SingleMessage.dart';
import 'package:sms_download/pages/FileManagerUI.dart';
import 'package:sms_maintained/sms.dart';
import 'package:firebase_admob/firebase_admob.dart';

class ActionsUI extends StatefulWidget {
  final smsThread;
  final smsMessageList;

  ActionsUI(this.smsThread, this.smsMessageList) {
    if (smsThread == null) {
      throw new ArgumentError("Selected record passed cannot be null. "
          "Received: '$smsThread");
    }
  }

  @override
  createState() => new ActionsUIState(smsThread, smsMessageList);
}

enum MenuChoices { fileManager, home }

class ActionsUIState extends State<ActionsUI> {
  InterstitialAd myInterstitial;

  SmsThread _currSmsThread;
  List<SmsMessage> _smsMessageList;
  SMSLib _smsLib = new SMSLib();
  FileIOLib _fileIOLib = new FileIOLib();

  File _exportedFile;
  bool _showOpenFileButton = false;

  String _allMessagesAsString;
  List<SingleMessage> _allMessagesAsList;
  String _processStatus = "Ready";
  bool _processing = false;

  MenuChoices _menuSelection;

  ActionsUIState(this._currSmsThread, this._smsMessageList);

  /// Build Interstitial Ad
  InterstitialAd buildInterstitialAd() {
    return InterstitialAd(
      adUnitId: InterstitialAd.testAdUnitId,
      listener: (MobileAdEvent event) {
        if (event == MobileAdEvent.failedToLoad) {
          myInterstitial..load();
        } else if (event == MobileAdEvent.closed) {
          myInterstitial = buildInterstitialAd()..load();
        }
        print(event);
      },
    );
  }

  /// Show Interstitial Ad (Random chance of showing. Use this to ease ads on user)
  void showRandomInterstitialAd() {
    Random r = new Random();
    bool value = r.nextBool();

    if (value == true) {
      myInterstitial..show();
    }
  }

  /// Show Interstitial Ad (100% of the time)
  void showInterstitialAd() {
    myInterstitial..show();
  }

  @override
  void initState() {
    super.initState();

    // Load Interstitial Ad
    myInterstitial = buildInterstitialAd()..load();
  }

  @override
  void dispose() {
    myInterstitial.dispose();

    super.dispose();
  }

  /// Handles Menu selections
  Future _menuItemSelected() async {
    if (_menuSelection == MenuChoices.fileManager)
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => FileManagerUI()));
    if (_menuSelection == MenuChoices.home)
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
  }

  /// Share messages requested
  _onPressedShareMessages(BuildContext context) async {
    bool dialogResult = await CommonFunctions.getConfirmationDialogResult(
        context, "Are you sure you want to continue?");

    if (dialogResult == null || dialogResult == false) return;

    setState(() {
      _processStatus = "\n";
      if (_currSmsThread == null) {
        _processStatus += "Nothing to share";
        return;
      }
      _processing = true;
      _processStatus += "Preparing. Please wait...";
    });

    if (_allMessagesAsString == null)
      _allMessagesAsString =
          await _smsLib.getAllMessagesAsString(_currSmsThread, _smsMessageList);

    ShareLib shareLib = new ShareLib();
    bool result = await shareLib.shareMessagesAsText(_allMessagesAsString);

    setState(() {
      _processing = false;
      _processStatus = "";
      if (!result)
        _processStatus +=
            "\nShare failed. Message file might be too large.\nYou can try manually locating the exported file and sharing it that way.";
      else
        _processStatus += "Ready";
    });
  }

  /// Download As TXT Requested
  _onPressedDownloadMessagesAsTXT(BuildContext context) async {
    bool dialogResult = await CommonFunctions.getConfirmationDialogResult(
        context, "Are you sure you want to continue?");

    if (dialogResult == null || dialogResult == false) return;

    // Show Interstitial Ad
    showInterstitialAd();

    setState(() {
      _showOpenFileButton = false;
      _processStatus = "\n";
      if (_currSmsThread == null) {
        _processStatus += "Nothing to export";
        return;
      }
      _processing = true;
      _processStatus += "Exporting to text file. Please wait...";
    });

    int fileSize;
    try {
      if (_allMessagesAsString == null)
        _allMessagesAsString = await _smsLib.getAllMessagesAsString(
            _currSmsThread, _smsMessageList);

      FileIOLib fileIOLib = new FileIOLib();
      _exportedFile = await fileIOLib.writeStringToExternalFile(
          _allMessagesAsString,
          _smsLib.getPhoneNumWithTimeStampAsString(_currSmsThread.address),
          "txt");
      fileSize = await _exportedFile.length();
    } catch (e) {
      setState(() {
        _processing = false;
        _processStatus =
            "\nExport failed. The file may be too big. You can try again.\n\n" +
                e.toString();

        return;
      });
    }

    setState(() {
      _processing = false;
      _processStatus = "\n";
      _processStatus += "Export completed to the following location:\n\n" +
          _exportedFile.path +
          "\n\nFile size: " +
          filesize(fileSize);

      _showOpenFileButton = true;
    });
  }

  /// Download As PDF Requested
  _onPressedDownloadMessagesAsPDF(BuildContext context) async {
    bool dialogResult = await CommonFunctions.getConfirmationDialogResult(
        context, "Are you sure you want to continue?");

    if (dialogResult == null || dialogResult == false) return;

    // Show Interstitial Ad
    showInterstitialAd();

    setState(() {
      _showOpenFileButton = false;
      _processStatus = "\n";
      if (_currSmsThread == null) {
        _processStatus += "Nothing to export";
        return;
      }
      _processing = true;
      _processStatus += "Exporting to PDF file. Please wait...";
    });

    int fileSize;
    try {
      _allMessagesAsList =
          await _smsLib.getAllMessagesAsList(_currSmsThread, _smsMessageList);

      PDFLib pdfLib = new PDFLib();
      String msgHeader =
          _smsLib.getHeader(_currSmsThread, _allMessagesAsList.length);
      String msgsAsHTML = pdfLib.getHtmlAsString(msgHeader, _allMessagesAsList);
      FileIOLib fileIOLib = new FileIOLib();
      _exportedFile = await fileIOLib.writePDFToExternalFile(msgsAsHTML,
          _smsLib.getPhoneNumWithTimeStampAsString(_currSmsThread.address));

      fileSize = await _exportedFile.length();
    } catch (e) {
      setState(() {
        _processing = false;
        _processStatus =
            "\nExport failed. The file may be too big. You can try again.\n\n" +
                e.toString();

        return;
      });
    }

    setState(() {
      _processing = false;
      _processStatus = "\nExport completed to the following location:\n\n" +
          _exportedFile.path +
          "\n\nFile size: " +
          filesize(fileSize);

      _showOpenFileButton = true;
    });
  }

  /// Open Exported File
  void _openFile() {
    try {
      _fileIOLib.openFile(_exportedFile.path);
    } catch (e) {
      setState(() {
        _processStatus = e.toString();
      });
    }
  }

  /// BUILD
  @override
  Widget build(BuildContext context) {
    debugPrint("Build: ActionsUI()");
    return Scaffold(
        // HEADER
        appBar: AppBar(
          title: ListTile(
              contentPadding: EdgeInsets.all(0.0),
              // CONTACT ICON
              leading: null,

              // APP TITLE
              title: Padding(
                padding: const EdgeInsets.only(bottom: 0.0),
                child: Text("Export or Share Conversation",
                    style: TextStyle(
                        color: UITheme.hdrTxtColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0)),
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
                      value: MenuChoices.fileManager,
                      child: Text('File Manager'),
                    ),
                    const PopupMenuItem<MenuChoices>(
                      value: MenuChoices.home,
                      child: Text('Home'),
                    ),
                  ],
                ),
              )),
          backgroundColor: UITheme.hdrBgColor,
        ),
        //BODY
        body: Card(
          child: Column(
            children: [
              ListTile(
                title: Text(_smsLib.getNameFromThread(_currSmsThread),
                    style: TextStyle(fontWeight: FontWeight.w500)),
                leading: Icon(
                  Icons.person,
                  color: UITheme.hdrBgColor,
                ),
              ),
              ListTile(
                title: Text(_smsLib.getNumFromThread(_currSmsThread),
                    style: TextStyle(fontWeight: FontWeight.w500)),
                leading: Icon(
                  Icons.phone,
                  color: UITheme.hdrBgColor,
                ),
              ),
              ListTile(
                title: Text(
                    _currSmsThread.messages.length.toString() + " message(s)"),
                leading: Icon(
                  Icons.message,
                  color: UITheme.hdrBgColor,
                ),
              ),
              Divider(
                thickness: 2.0,
              ),
              ListTile(
                title: InkWell(
                  child: FlatButton(
                    color: UITheme.hdrBgColor,
                    child: Text(
                      "Download to Device (TXT)",
                      style: TextStyle(color: UITheme.hdrTxtColor),
                    ),
                    onPressed: () => _onPressedDownloadMessagesAsTXT(context),
                  ),
                ),
                leading: Icon(
                  Icons.file_download,
                  color: UITheme.hdrBgColor,
                ),
              ),
              ListTile(
                title: InkWell(
                  child: FlatButton(
                    color: UITheme.hdrBgColor,
                    child: Text(
                      "Download to Device (PDF)",
                      style: TextStyle(color: UITheme.hdrTxtColor),
                    ),
                    onPressed: () => _onPressedDownloadMessagesAsPDF(context),
                  ),
                ),
                leading: Icon(
                  Icons.picture_as_pdf,
                  color: UITheme.hdrBgColor,
                ),
              ),
              ListTile(
                title: InkWell(
                  child: FlatButton(
                    color: UITheme.hdrBgColor,
                    child: Text(
                      "Share",
                      style: TextStyle(color: UITheme.hdrTxtColor),
                    ),
                    onPressed: () => _onPressedShareMessages(context),
                  ),
                ),
                leading: Icon(
                  Icons.share,
                  color: UITheme.hdrBgColor,
                ),
              ),
              Divider(
                thickness: 2.0,
              ),
              ListTile(
                title: Text(
                  "Status",
                  style: TextStyle(color: UITheme.hdrBgColor),
                ),
                leading: !_processing
                    ? Icon(
                        Icons.info_outline,
                        color: UITheme.hdrBgColor,
                      )
                    : UITheme.getLoadingWidget(),
                subtitle: Text(_processStatus),
              ),
              _showOpenFileButton
                  ? ListTile(
                      title: InkWell(
                        child: FlatButton(
                          color: UITheme.hdrBgColor,
                          child: Text(
                            "Open File",
                            style: TextStyle(color: UITheme.hdrTxtColor),
                          ),
                          onPressed: () => _openFile(),
                        ),
                      ),
                      leading: Icon(
                        null,
                        color: UITheme.hdrBgColor,
                      ),
                    )
                  : Text(""),
            ],
          ),
        ),
        bottomNavigationBar: new Container(
          color: UITheme.hdrBgColor,
          height: 50.0,
        ));
  }
}
