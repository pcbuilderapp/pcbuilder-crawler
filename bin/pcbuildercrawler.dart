import 'package:pcbuilder.crawler/alternate/crawlternate.dart';
import 'package:pcbuilder.crawler/informatique/informacrawl.dart';

main(List<String> args) async {
  Informacrawl.crawlInformatique();
  Crawlternate.crawlAlternate();
}