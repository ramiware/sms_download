import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sms_download/appcore/AppConstants.dart';
import 'package:sms_download/appcore/CommonFunctions.dart';
import 'package:sms_download/appcore/UITheme.dart';
import 'package:sms_download/logic/SMSLib.dart';
import 'package:sms_download/pages/FileManagerUI.dart';
import 'package:sms_download/pages/SingleThreadUI.dart';
import 'package:sms_maintained/sms.dart';

class ThreadListUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.APP_TITLE,
      // home: TitlePage(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        // When we navigate to the "/" route, build the FirstScreen Widget
        '/': (context) => ThreadListPage(),
      },
    );
  }
}

class ThreadListPage extends StatefulWidget {
  // debugPrint("Build: ThreadListPage()");

  @override
  _ThreadListPageState createState() => _ThreadListPageState();
}

enum MenuChoices {
  search,
  dateNewestFirst,
  dateOldestFirst,
  refreshThreads,
  fileManager,
  about
}

class _ThreadListPageState extends State<ThreadListPage>
    with SingleTickerProviderStateMixin {
  BannerAd myBanner;

  List<SmsThread> _smsThreadList;
  SMSLib _smsLib = new SMSLib();

  MenuChoices _menuSelection;

  /// Filter ListView
  bool _showSearchBar = false;
  TextEditingController _searchController = new TextEditingController();
  String _searchString;

  /// Animation variables
  AnimationController _animController;
  int _selectedIndex = -1;

  /// Loading threads
  bool _loadingThreads = true;

  /// Build Rectangle Banner Ad
  BannerAd buildBannerAd() {
    return BannerAd(
        adUnitId: BannerAd.testAdUnitId,
        size: AdSize.banner,
        listener: (MobileAdEvent event) {
          if (event == MobileAdEvent.loaded) {
            myBanner..show();
          }
        });
  }

  @override
  void initState() {
    super.initState();

    // Initialize and Load Banner Ad
    FirebaseAdMob.instance.initialize(appId: FirebaseAdMob.testAppId);
    myBanner = buildBannerAd()..load();

    _loadThreads();

    // Filter ListView
    _searchController.addListener(() {
      setState(() {
        _searchString = _searchController.text;
      });
    });

    // Animation
    _animController = new AnimationController(
      vsync: this,
      duration: new Duration(milliseconds: 500),
    );

    _animController.addListener(() {
      this.setState(() {});
    });
  }

  @override
  void dispose() {
    myBanner.dispose();
    super.dispose();
  }

  /// Loads all SMS threads into a list
  Future<bool> _loadThreads() async {
    _loadingThreads = true;
    debugPrint("loadThreads()");

    _smsThreadList = await _smsLib.getAllThreads();
    _loadingThreads = false;

    this.setState(() {});

    if (_smsThreadList == null || _smsThreadList.length == 0)
      return false;
    else
      return true;
  }

  /// Handles Menu selections
  Future _menuItemSelected() async {
    if (_menuSelection == MenuChoices.search) _showSearchBar = true;
    if (_menuSelection == MenuChoices.dateOldestFirst)
      _smsThreadList.sort(
          (a, b) => a.messages.first.date.compareTo(b.messages.first.date));
    else if (_menuSelection == MenuChoices.dateNewestFirst)
      _smsThreadList.sort(
          (a, b) => b.messages.first.date.compareTo(a.messages.first.date));
    else if (_menuSelection == MenuChoices.refreshThreads)
      await _loadThreads();
    else if (_menuSelection == MenuChoices.fileManager)
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => FileManagerUI()));
    else if (_menuSelection == MenuChoices.about) _onTapAboutMenuChoice();
  }

  /// Display App Info, version
  void _onTapAboutMenuChoice() {
    debugPrint("About Menu Selected");

    var alert = new AlertDialog(
      titlePadding: EdgeInsets.all(0.0),
      title: Container(
        color: UITheme.hdrBgColor,
        child: ListTile(
          title: Text(
            "About",
            style: TextStyle(
                color: UITheme.hdrTxtColor,
                fontWeight: FontWeight.bold,
                fontSize: 18.0),
          ),
          trailing: Icon(
            Icons.help_outline,
            color: UITheme.hdrTxtColor,
          ),
        ),
      ),
      content: Text(AppConstants.APP_TITLE +
          "\n" +
          AppConstants.APP_VERSION +
          "\n\n" +
          // Common.APP_COMPANY +
          // "\n" +
          AppConstants.APP_SITE),
      actions: <Widget>[
        new FlatButton(
          child: new Text(
            'OK',
            style: TextStyle(color: UITheme.hdrBgColor),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );

    showDialog(context: context, builder: (context) => alert);
  }

  /// Contact ListTile clicked
  _onTapContactItem(BuildContext context, SmsThread thread, int selectedIndex) {
    debugPrint("onPressed: Thread Pressed->" +
        _smsLib.getNameFromThread(thread) +
        "[" +
        _smsLib.getNumFromThread(thread) +
        "]");

    // Animation
    _selectedIndex = selectedIndex;
    _animController.forward(from: 0.0);

    Navigator.push(context,
        MaterialPageRoute(builder: (context) => SingleThreadUI(thread)));
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

            // LEADING - CUSTOM ICON
            // leading: new Image.asset(
            //     'assets/images/icon-template-x-large-transparentBG.png',
            //     width: 45.0,
            //     height: 45.0,
            //     fit: BoxFit.cover),
            // LEADING - GENERIC ICON
            // leading: new Icon(
            //   Icons.sms,
            //   color: UITheme.hdrTxtColor,
            //   size: 30.0,
            // ),

            // APP TITLE
            title: Padding(
              padding: const EdgeInsets.only(bottom: 0.0),
              child: Text(AppConstants.APP_TITLE,
                  style: TextStyle(
                      color: UITheme.hdrTxtColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0)),
            ),

            // SUBTITLE
            subtitle: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  "Select a conversation",
                  style: TextStyle(color: UITheme.hdrTxtColor, fontSize: 12.0),
                ),
              ),
            ),

            // MENU ICON
            trailing: Container(
              // color: Colors.red,
              width: 105.0,
              child: Row(
                children: <Widget>[
                  IconButton(
                    alignment: Alignment.centerRight,
                    icon: Icon(Icons.search, color: UITheme.hdrTxtColor),
                    onPressed: () {
                      setState(() {
                        _showSearchBar = true;
                      });
                    },
                  ),
                  InkWell(
                    child: PopupMenuButton<MenuChoices>(
                      icon: Icon(
                        Icons.more_vert,
                        color: UITheme.hdrTxtColor,
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
                          value: MenuChoices.refreshThreads,
                          child: Text('Refresh Messages'),
                        ),
                        const PopupMenuItem<MenuChoices>(
                          value: MenuChoices.fileManager,
                          child: Text('File Manager'),
                        ),
                        const PopupMenuItem<MenuChoices>(
                          value: MenuChoices.about,
                          child: Text('About'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
        backgroundColor: UITheme.hdrBgColor,
      ),

      // BODY
      body: (_loadingThreads)
          ? Center(child: UITheme.getLoadingWidget())
          : Column(
              children: <Widget>[
                // SEARCH BAR
                (_showSearchBar)
                    ? ListTile(
                        leading: Icon(Icons.search),
                        title: TextField(
                            cursorColor: UITheme.hdrBgColor,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              labelText: "Search for contact...",
                              labelStyle: TextStyle(
                                color: UITheme.hdrBgColor,
                              ),
                            ),
                            controller: _searchController),
                        trailing: InkWell(child: Icon(Icons.clear)),
                        onTap: () => _closeSearchBar())
                    : Container(),

                // LIST VIEW: THREADS LIST
                Expanded(
                  child: Scrollbar(
                    child: ListView.builder(
                        itemCount:
                            _smsThreadList == null ? 0 : _smsThreadList.length,
                        itemBuilder: (BuildContext context, int index) {
                          // LOGIC FOR FILTERING
                          return (_smsLib.findStringInThreadContact(
                                  _smsThreadList[index], _searchString)
                              ? Padding(
                                  padding: const EdgeInsets.all(0.0),
                                  child: Container(
                                    // HIGHLIGHT SELECTION
                                    decoration: BoxDecoration(
                                        color: (_animController.isAnimating)
                                            ? (index == _selectedIndex)
                                                ? UITheme.highlightBgColor
                                                : UITheme.hdrTxtColor
                                            : UITheme.hdrTxtColor,
                                        border: Border.all(
                                            color: UITheme.bodyTxt2Color,
                                            width: 0.25)),
                                    child: ListTile(
                                      // LEADING
                                      leading: (_smsThreadList[index]
                                                  .contact
                                                  .fullName ==
                                              null
                                          ? Icon(Icons.person_outline)
                                          : Icon(Icons.person)),

                                      // TITLE
                                      title: Text(
                                          _smsLib.getNameOrNumberFromThread(
                                              _smsThreadList[index]),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15.0)),

                                      // SUBTITLE
                                      subtitle: Container(
                                        height: 30,
                                        child: Text(
                                            _smsThreadList[index]
                                                .messages
                                                .first
                                                .body,
                                            style: TextStyle(
                                                fontSize: 11.0,
                                                color: UITheme.bodyTxt2Color)),
                                      ),

                                      // TRAILING
                                      trailing: Text(
                                        CommonFunctions.getDateAsFriendlyFormat(
                                            _smsThreadList[index]
                                                .messages
                                                .first
                                                .date),
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 11.0,
                                            color: UITheme.bodyTxt2Color),
                                      ),

                                      // ON TAP
                                      onTap: () => _onTapContactItem(context,
                                          _smsThreadList[index], index),
                                    ),
                                  ),
                                )
                              : Container());
                        }),
                  ),
                ),
              ],
            ),

      // FOOTER
      // bottomNavigationBar: new Container(
      //   color: UITheme.hdrBgColor,
      //   height: 100.0,

      // child: ListTile(
      //   // TITLE
      //   title: Text("Conversations",
      //       style: TextStyle(
      //           color: UITheme.hdrTxtColor,
      //           fontWeight: FontWeight.bold,
      //           fontSize: 15.0)),
      //   // TRAILING
      //   trailing: Text(
      //     _smsThreadList == null
      //         ? "0"
      //         : _smsThreadList.length.toString(),
      //     style: TextStyle(
      //         color: UITheme.hdrTxtColor,
      //         fontWeight: FontWeight.bold,
      //         fontSize: 15.0),
      //   ),
      // )),

      bottomNavigationBar: new Container(
          color: UITheme.hdrBgColor,
          height: 100.0,
          child: Column(
            children: <Widget>[
              Container(
                height: 50.0,
                color: UITheme.hdrBgColor,
                child: ListTile(
                  // TITLE
                  title: Text("Conversations",
                      style: TextStyle(
                          color: UITheme.hdrTxtColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15.0)),
                  // TRAILING
                  trailing: Text(
                    _smsThreadList == null
                        ? "0"
                        : _smsThreadList.length.toString(),
                    style: TextStyle(
                        color: UITheme.hdrTxtColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0),
                  ),
                ),
              ),
              Container(height: 50.0, color: Colors.black, child: ListTile())
            ],
          )),
    );
  }
}
