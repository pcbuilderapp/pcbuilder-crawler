import 'package:pcbuilder.crawler/alternate/crawlternate.dart';
import 'package:pcbuilder.crawler/informatique/informacrawl.dart';
import 'dart:io';
import 'dart:async';

main(List<String> args) async {
  new Timer.periodic(new Duration(minutes: 1),(Timer timer){
    DateTime currentTime = new DateTime.now();
    if (currentTime.hour == 4) {
      Informacrawl.crawlInformatique();
      Crawlternate.crawlAlternate();
    }
  });
}