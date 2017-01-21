import 'package:pcbuilder.crawler/alternate/crawlternate.dart';
import 'package:pcbuilder.crawler/informatique/informacrawl.dart';
import 'package:pcbuilder.crawler/config.dart';
import 'dart:io';
import "package:pcbuilder.crawler/model/metrics.dart";

main(List<String> args) async {
  File cfgFile = new File("config.yaml");

  try {
    String yamlSrc = await cfgFile.readAsString();
    config.init(yamlSrc);
  } catch (e) {
    print(e);
  }

  Crawlternate crawlternate = new Crawlternate();
  Metrics altermetrics = new Metrics();
  crawlternate.crawl(altermetrics);

  Informacrawl informacrawl = new Informacrawl();
  Metrics informetrics = new Metrics();
  await informacrawl.crawl(informetrics);

  altermetrics.printMetrics();
  informetrics.printMetrics();
}
