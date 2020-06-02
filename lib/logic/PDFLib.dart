import 'package:sms_download/models/SingleMessage.dart';

class PDFLib {

  /// Returns all messages in HTML format
  String getHtmlAsString(String msgHeader, List<SingleMessage> msgList) {

    var htmlContent = """
    <!DOCTYPE html>
    <html>
    <head>
        <style>
        table, th, td {
          border: 1px solid black;
          border-collapse: collapse;
          font-size: 11px;
          font-weight: normal;
          font-family: Tahoma, Geneva, Verdana, sans-serif;
        }
        th, td, p {
          padding: 5px;
          text-align: left;
          font-size: 11px;
          font-weight: normal;
          font-family: Tahoma, Geneva, Verdana, sans-serif;
        }
        </style>
      </head>
      <body>
        <table style="width:100%">
          <caption>""" + msgHeader.replaceAll("\n", "<br>") + """</caption>
          <tr style="background-color:lightgray">
            <th style="font-weight: bold">Msg ID</th>
            <th style="font-weight: bold">Time Stamp</th>
            <th style="font-weight: bold">Msg Type</th>
            <th style="font-weight: bold">Msg Body</th>
          </tr>""";

    for (var msg in msgList) {
      htmlContent += """
          <tr>
            <th>""" +
          msg.counter +
          """</th>
            <th>""" +
          msg.dateTimeStamp +
          """</th>
            <th>""" +
          msg.type +
          """</th>
            <th>""" +
          msg.body +
          """</th>
          </tr>""";
    }

    htmlContent += """
        </table>
      </body>
    </html>
    """;

    return htmlContent;
  }
}
