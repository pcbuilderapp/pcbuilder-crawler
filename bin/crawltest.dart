import 'package:pcbuilder.crawler/alternate/crawlternate.dart';
import 'package:pcbuilder.crawler/informatique/informacrawl.dart';
import 'package:pcbuilder.crawler/config.dart';
import 'dart:io';

main(List<String> args) async {

  File cfgFile = new File("config.yaml");

  try {
    String yamlSrc = await cfgFile.readAsString();
    config.init(yamlSrc);
  } catch (e) {
    print(e);
  }

  Crawlternate crawlternate = new Crawlternate();
  Informacrawl informacrawl = new Informacrawl();

  crawlternate.crawlShop();
  informacrawl.crawlShop();
}
