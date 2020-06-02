import 'package:date_format/date_format.dart';
import 'package:flutter/foundation.dart';
import 'package:sms_download/appcore/AppConstants.dart';
import 'package:sms_download/models/SingleMessage.dart';
import 'package:sms_maintained/sms.dart';

class SMSLib {
  SmsQuery _smsQuery;
  List<SmsThread> _threads;

  List<SmsMessage> _messages;

  /// Constructor
  SMSLib() {
    _smsQuery = new SmsQuery();
  }

  /// Returns TRUE if the searchString exists in the thread.address or
  /// thread.contact.fullname
  bool findStringInThreadContact(SmsThread thread, String searchString) {
    if (searchString == null || searchString == "") {
      return true;
    }

    if (thread.address.contains(searchString)) {
      return true;
    }

    if (thread.contact.fullName != null &&
        thread.contact.fullName
            .toLowerCase()
            .contains(searchString.toLowerCase())) {
      return true;
    }

    return false;
  }

  /// Returns TRUE if the searchString exists in the msg.body
  bool findStringInMessage(SmsMessage msg, String searchString) {
    if (searchString == null || searchString == "") {
      return true;
    }

    if (msg.body.contains(searchString)) {
      return true;
    }

    return false;
  }

  /// Get name of contact from thread
  String getNameFromThread(SmsThread thread) {
    if (thread == null) return "Thread Empty";

    if (thread.contact.fullName == null || thread.contact.fullName.length == 0)
      return "Contact Not Saved";
    else
      return thread.contact.fullName;
  }

  /// Get phone number from thread
  String getNumFromThread(SmsThread thread) {
    if (thread == null) return "Thread Empty";

    return thread.contact.address.toString();
  }

  /// Returns the contact name.
  /// If the name is not available, returns the number
  String getNameOrNumberFromThread(SmsThread thread) {
    if (thread == null) return "Thread Empty";

    if (thread.contact.fullName == null || thread.contact.fullName.length == 0)
      return thread.contact.address.toString();
    else
      return thread.contact.fullName;
  }

  /// Returns a filename with no extension using the contact address
  String getPhoneNumWithTimeStampAsString(String address) {
    String dateTimeNow = DateTime.now().year.toString() +
        DateTime.now().month.toString() +
        DateTime.now().day.toString() +
        "_" +
        DateTime.now().hour.toString() +
        DateTime.now().minute.toString() +
        DateTime.now().second.toString();
    String filename = address.replaceAll("+", "") + "_" + dateTimeNow;

    return filename;
  }

  /// Returns all threads as a SmsThread List
  Future<List<SmsThread>> getAllThreads() async {
    _threads = await _smsQuery.getAllThreads;
    return _threads;
  }

  /// Returns all messages for the specified threadIDd
  Future<List<SmsMessage>> getAllMessages(int threadID) async {
    _messages = await _smsQuery.querySms(
        threadId: threadID,
        kinds: [SmsQueryKind.Inbox, SmsQueryKind.Sent, SmsQueryKind.Draft]);

    return _messages;
  }

  /// Returns a string header with the SmsMessageList info
  String getHeader(SmsThread thread, int messageCount) {
    String contactName, contactNum;

    contactNum = thread.address;

    if (thread.contact.fullName == null || thread.contact.fullName.length == 0)
      contactName = "Contact Name N/A";
    else
      contactName = thread.contact.fullName;

    String header = "Export created by " +
        AppConstants.APP_TITLE +
        " " +
        AppConstants.APP_VERSION +
        "\nCreated by " +
        AppConstants.APP_COMPANY +
        " [" +
        AppConstants.APP_SITE +
        "]" +
        "\n";
    header +=
        "\nContact Name: " + contactName + "\n" + "Phone Number: " + contactNum;
    header += "\n" + messageCount.toString() + " message(s) found\n\n";

    return header;
  }

  /// Returns all messages for a single thread as a String object
  Future<String> getAllMessagesAsString(
      SmsThread thread, List<SmsMessage> smsMessageList) async {
    if (thread == null) return "No data";

    List<Object> parmList = new List<Object>();
    parmList.add(smsMessageList);
    // parmList.add(thread);

    String messagesAsString = getHeader(thread, smsMessageList.length);

    messagesAsString +=
        await compute(_generateAllMessagesAsSingleString, parmList);

    return messagesAsString;
  }

  /// Returns all messages for a single thread as a List<SingleMessage> object
  Future<List<SingleMessage>> getAllMessagesAsList(
      SmsThread thread, List<SmsMessage> smsMessageList) async {
    if (thread == null) return null;

    List<Object> parmList = new List<Object>();
    parmList.add(smsMessageList);
    // parmList.add(thread);

    List<SingleMessage> messagesAsList =
        await compute(_generateAllMessagesAsList, parmList);

    return messagesAsList;
  }

  /// Static method. Returns all messages as a single String.
  /// Set as static so that it can be used with a compute()
  static String _generateAllMessagesAsSingleString(List<Object> parms) {
    List<SmsMessage> messages = parms[0];

    String fileData = "";

    // String year, month, day, hour, minute, second;
    String dateTimeFormatted;
    for (int i = 0; i < messages.length; i++) {
      dateTimeFormatted = formatDate(messages[i].date,
          [yyyy, '-', mm, '-', dd, ' ', hh, ':', nn, ':', ss, ' ', am]);

      fileData += "[" +
          (i + 1).toString() +
          "-" +
          (messages.length).toString() +
          "]" +
          "[" +
          dateTimeFormatted +
          "] ";

      fileData += (messages[i].kind.index == 0) ? "Sent\n" : "Received\n";

      fileData += messages[i].body;
      fileData += "\n";
    }

    return fileData;
  }

  /// Static method. Returns all messages in a List
  /// Set as static so that it can be used with a compute()
  static List<SingleMessage> _generateAllMessagesAsList(List<Object> parms) {
    List<SmsMessage> messages = parms[0];

    SingleMessage singleMsg;
    List<SingleMessage> singleMsgsList = new List<SingleMessage>();

    // String year, month, day, hour, minute, second;
    String dateTimeFormatted;
    for (int i = 0; i < messages.length; i++) {
      singleMsg = new SingleMessage();

      dateTimeFormatted = formatDate(messages[i].date,
          [yyyy, '-', mm, '-', dd, ' ', hh, ':', nn, ':', ss, ' ', am]);

      singleMsg.counter = (i + 1).toString();

      singleMsg.dateTimeStamp = dateTimeFormatted;

      singleMsg.type = (messages[i].kind.index == 0) ? "Sent" : "Received";

      singleMsg.body = messages[i].body;

      singleMsgsList.add(singleMsg);
    }

    return singleMsgsList;
  }
}
