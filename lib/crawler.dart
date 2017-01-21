import 'package:pcbuilder.crawler/utils.dart';
import 'package:pcbuilder.crawler/interface/pageworker.dart';

import 'dart:async';
import 'package:html/dom.dart';
export 'package:html/dom.dart';
import 'package:html/parser.dart' as HtmlParser;
import 'package:http/http.dart' as Http;

///Crawler supplies methods to crawl internet webpages
class Crawler {

  ///Crawl a list of pages containing the same component type
  static crawlComponent(List<String> urls, PageWorker pageWorker) async {
    for (String url in urls) {
      await crawl(url, pageWorker);
    }
  }

  ///Crawl a page using a pageworker
  static Future crawl(String url, PageWorker worker, {arguments}) async {
    Map headers = getHTTPHeaders(url);
    String content = await Http.read(url, headers: headers);
    Document document = HtmlParser.parse(content);
    return worker.parse(document, arguments);
  }
}
