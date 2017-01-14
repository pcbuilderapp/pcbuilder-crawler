import 'package:pcbuilder.crawler/utils.dart';
import 'dart:async';
import 'package:html/dom.dart';
export 'package:html/dom.dart';
import 'package:html/parser.dart' as HtmlParser;
import 'package:http/http.dart' as Http;

///PageWorker abstract class should implement a parse function///
abstract class PageWorker {
    parse(Document document, arguments);
}

///Crawler supplies methods to crawl internet webpages///
class Crawler {

  ///Crawl a page using a pageworker///
  static Future crawl(String url, PageWorker worker, {arguments}) async {
    Map headers = getHTTPHeaders(url);
    String content = await Http.read(url, headers: headers);
    Document document = HtmlParser.parse(content);
    return worker.parse(document, arguments);
  }

  ///Crawl a list of pages containing the same component type///
  static crawlComponent(List<String> urls, PageWorker pageWorker) async {
    for (String url in urls) {
      await crawl(url, pageWorker);
    }
  }
}
