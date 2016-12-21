import 'package:pcbuilder.crawler/crawler.dart';
import 'package:pcbuilder.crawler/alternate/parsers/motherboard.dart';
import "package:pcbuilder.crawler/utils.dart";
import "package:pcbuilder.crawler/model/shop.dart";
import 'dart:convert';
import 'dart:io';
import 'dart:async';

class Crawlternate {

  static Future crawlAlternate() async {
    try {

      postRequest(getBackendServerURL()+"/shop/create", new JsonEncoder.withIndent("  ").convert(new Shop("Alternate", "https://www.alternate.nl", "https://www.alternate.nl/pix/header/logo/slogan/alternate.png")));

      // MOTHERBOARDS //
      List motherboards = await Crawler.crawl(
        "https://www.alternate.nl/Hardware-Componenten-Moederborden-Intel/html/listings/11626?lk=9435&size=500&showFilter=true#listingResult",
        new MotherboardParser(),
        referrer: "https://www.alternate.nl/Moederborden/Intel", /*cookies:cookies*/);

      String json = new JsonEncoder.withIndent("  ").convert(motherboards);
      print("We hebben ${motherboards.length} moederborden gevonden.");
      File alternateIntelMotherboards = new File(
          "alternmate_intel_motherboards.json");
      alternateIntelMotherboards.writeAsStringSync(json);

      // MEM //



    } catch (e) {
      print(e);
    }
  }
}
