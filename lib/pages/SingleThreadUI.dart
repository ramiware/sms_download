import 'package:bubble/bubble.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:sms_download/appcore/CommonFunctions.dart';
import 'package:sms_download/appcore/UITheme.dart';
import 'package:sms_download/logic/SMSLib.dart';
import 'package:sms_download/pages/ActionsUI.dart';
import 'package:sms_maintained/sms.dart';

class SingleThreadUI extends StatefulWidget {
  final smsThread;

  SingleThreadUI(this.smsThread) {
    if (smsThread == null) {
      throw new ArgumentError("Selected record passed cannot be null. "
          "Received: '$smsThread");
    }
  }

  @override
  createState() => new SingleThreadUIState(smsThread);
}

enum MenuChoices { search, dateNewestFirst, dateOldestFirst, export_share }
enum SortOrder { OldtoNew, NewtoOld }

class SingleThreadUIState extends State<SingleThreadUI> {
  SmsThread _currSmsThread;
  List<SmsMessage> _smsMessageList;
  SMSLib _smsLib = new SMSLib();

  String _runningDate = "0";
  MenuChoices _menuSelection;

  /// Filter ListView
  bool _showSearchBar = false;
  TextEditingController _searchController = new TextEditingController();
  String _searchString;

  SingleThreadUIState(this._currSmsThread);

  @override
  void initState() {
    super.initState();
    _loadMessages(_currSmsThread.threadId, SortOrder.OldtoNew);

    // Filter ListView
    _searchController.addListener(() {
      setState(() {
        _searchString = _searchController.text;
      });
    });
  }

  /// Loads all SMS messages into a list
  Future<bool> _loadMessages(int threadID, SortOrder order) async {
    debugPrint("loadMessages()");

    _runningDate = "0";
    _smsMessageList = await _smsLib.getAllMessages(threadID);

    if (order == SortOrder.OldtoNew)
      _smsMessageList.sort((a, b) => a.date.compareTo(b.date));
    else if (order == SortOrder.NewtoOld)
      _smsMessageList.sort((a, b) => b.date.compareTo(a.date));

    this.setState(() {});

    if (_smsMessageList == null || _smsMessageList.length == 0)
      return false;
    else
      return true;
  }

  /// Handles Menu selections
  Future _menuItemSelected() async {
    if (_menuSelection == MenuChoices.search) _showSearchBar = true;
    if (_menuSelection == MenuChoices.dateOldestFirst)
      _loadMessages(_currSmsThread.threadId, SortOrder.OldtoNew);
    else if (_menuSelection == MenuChoices.dateNewestFirst)
      _loadMessages(_currSmsThread.threadId, SortOrder.NewtoOld);
    else if (_menuSelection == MenuChoices.export_share)
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ActionsUI(_currSmsThread, _smsMessageList)));
  }

  /// Returns the time as a widget to compliment the bubbles
  Widget _getTimeWidget(String timeAsString) {
    return Padding(
      padding:
          const EdgeInsets.only(left: 30.0, right: 30.0, top: 5, bottom: 5),
      child: Text(timeAsString,
          style: TextStyle(color: Colors.grey, fontSize: 9.0)),
    );
  }

  /// Only returns a bubble if the date has changed
  Widget _getNewDayBubble(SmsMessage currMsg) {
    String currMsgDate =
        formatDate(currMsg.date, [DD, ', ', MM, ' ', dd, ', ', yyyy]);

    // First time only - set the _runningDate to curr msg date
    if (_runningDate == null || _runningDate.length == 0)
      _runningDate = currMsgDate;

    // If we are still on the same date, simply return
    if (_runningDate == currMsgDate)
      return Text("", style: TextStyle(fontSize: 0.1));

    // If the dates are different, update the _running date value
    // and return a bubble with the new day we are on
    _runningDate = currMsgDate;

    return Bubble(
        alignment: Alignment.center,
        color: Color.fromRGBO(212, 234, 244, 1.0),
        child: Text(currMsgDate,
            textAlign: TextAlign.center, style: TextStyle(fontSize: 11.0)));

    // margin: BubbleEdges.only(top: 10, left: 10.0, right: 105),
  }

  /// Returns the message in a bubble display
  Widget _getMsgBubble(SmsMessage currMsg) {
    if (currMsg.kind == SmsMessageKind.Received) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _getNewDayBubble(currMsg),
          Bubble(
              margin: BubbleEdges.only(top: 5, left: 10, right: 105, bottom: 0),
              alignment: Alignment.topLeft,
              nipWidth: 8,
              nipHeight: 5,
              nip: BubbleNip.leftTop,
              child: Column(children: <Widget>[
                Text(currMsg.body),
              ])),
          _getTimeWidget(CommonFunctions.getTimeAsFriendlyFormat(currMsg.date)),
        ],
      );
    }
    if (currMsg.kind == SmsMessageKind.Sent) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _getNewDayBubble(currMsg),
          Bubble(
              margin: BubbleEdges.only(top: 5, right: 10, left: 105, bottom: 0),
              alignment: Alignment.topRight,
              nipWidth: 8,
              nipHeight: 5,
              nip: BubbleNip.rightTop,
              color: Color.fromRGBO(225, 255, 199, 1.0),
              child: Text(currMsg.body)),
          _getTimeWidget(CommonFunctions.getTimeAsFriendlyFormat(currMsg.date)),
        ],
      );
    }

    return null;
  }

  /// Handles closing and clearing the search bar
  void _closeSearchBar() {
    _searchController.text = "";
    _showSearchBar = false;
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

            // TITLE
            title: Padding(
              padding: const EdgeInsets.only(bottom: 0.0),
              child: Text(_smsLib.getNameOrNumberFromThread(_currSmsThread),
                  style: TextStyle(
                      color: UITheme.hdrTxtColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0)),
            ),

            // SUBTITLE
            subtitle: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Text(
                _smsLib.getNumFromThread(_currSmsThread),
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
                    value: MenuChoices.search,
                    child: Text('Search...'),
                  ),
                  const PopupMenuItem<MenuChoices>(
                    value: MenuChoices.dateNewestFirst,
                    child: Text('Sort Date Newest First'),
                  ),
                  const PopupMenuItem<MenuChoices>(
                    value: MenuChoices.dateOldestFirst,
                    child: Text('Sort Date Oldest First'),
                  ),
                  const PopupMenuItem<MenuChoices>(
                    value: MenuChoices.export_share,
                    child: Text('Export/Share'),
                  ),
                ],
              ),
            )),
        backgroundColor: UITheme.hdrBgColor,
      ),

      // BODY
      body: Column(
        children: <Widget>[
          // SEARCH BAR
          (_showSearchBar)
              ? ListTile(
                  leading: Icon(Icons.search),
                  title: TextField(
                      cursorColor: UITheme.hdrBgColor,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: "Search messages...",
                        labelStyle: TextStyle(
                          color: UITheme.hdrBgColor,
                        ),
                      ),
                      controller: _searchController),
                  trailing: InkWell(child: Icon(Icons.clear)),
                  onTap: () => _closeSearchBar())
              : Container(),

          // LIST VIEW: MSGS BODY
          Expanded(
            child: Scrollbar(
              child: ListView.builder(
                itemCount: _smsMessageList == null ? 0 : _smsMessageList.length,
                itemBuilder: (BuildContext context, int index) {
                  return (_smsLib.findStringInMessage(
                          _smsMessageList[index], _searchString)
                      ? _getMsgBubble(_smsMessageList[index])
                      : Container());
                },
              ),
            ),
          ),
        ],
      ),

      // FOOTER
      // bottomNavigationBar: new Container(
      //     color: UITheme.hdrBgColor,
      //     height: 50.0,
      //     child: ListTile(
      //       title: Text("Messages",
      //           style: TextStyle(
      //               color: UITheme.hdrTxtColor, fontWeight: FontWeight.bold)),
      //       trailing: Text(
      //         _smsMessageList == null ? "0" : _smsMessageList.length.toString(),
      //         style: TextStyle(
      //             color: UITheme.hdrTxtColor,
      //             fontWeight: FontWeight.bold,
      //             fontSize: 20.0),
      //       ),
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
                  title: Text("Messages",
                      style: TextStyle(
                          color: UITheme.hdrTxtColor,
                          fontWeight: FontWeight.bold)),
                  trailing: Text(
                    _smsMessageList == null
                        ? "0"
                        : _smsMessageList.length.toString(),
                    style: TextStyle(
                        color: UITheme.hdrTxtColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0),
                  ),
                ),
              ),
              Container(height: 50.0, color: Colors.black, child: ListTile())
            ],
          )),
    );
  }
}
