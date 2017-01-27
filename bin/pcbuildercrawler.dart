import 'package:pcbuilder.crawler/alternate/crawlternate.dart';
import 'package:pcbuilder.crawler/informatique/informacrawl.dart';
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
  
  Crawlternate crawlternate = new Crawlternate();
  Informacrawl informacrawl = new Informacrawl();
  
  new Timer.periodic(new Duration(minutes: 1),(Timer timer){
    DateTime currentTime = new DateTime.now();
    if (currentTime.hour == 4) {
      crawlternate.crawlShop();
      informacrawl.crawlShop();
    }
  });
}
