import 'package:pcbuilder.crawler/alternate/crawlternate.dart';
import 'package:pcbuilder.crawler/informatique/informacrawl.dart';
import 'package:pcbuilder.crawler/config.dart';
import 'dart:io';
import 'dart:async';

main(List<String> args) async {

  File cfgFile = new File("config.yaml");

  try {
    String yamlSrc = await cfgFile.readAsString();
    config.init(yamlSrc);
  } catch (e) {
    print(e);
  }

  Informacrawl.crawlInformatique();
  Crawlternate.crawlAlternate();
}