import 'package:pcbuilder.crawler/utils.dart';
import 'dart:async';
import 'package:html/dom.dart';
export 'package:html/dom.dart';
import 'package:html/parser.dart' as HtmlParser;
import 'package:http/http.dart' as Http;

abstract class PageWorker {
    parse(Document document, arguments);
}

class Crawler {
  static Future crawl(String url, PageWorker worker, {Map postData, String referrer, Map<String,String> cookies, arguments}) async {
    String content;
    Map headers = getHTTPHeaders(url, referrer: referrer, cookies: cookies);

    if (postData == null) {
      content = await Http.read(url,headers: headers);
    } else {
      content = (await Http.post(url,body: postData,headers: headers)).body;
    }
    Document document = HtmlParser.parse(content);
    return worker.parse(document, arguments);
  }
}
