import 'package:pcbuilder.crawler/crawler.dart';
import 'package:pcbuilder.crawler/alternate/parsers/alternateParseMotherboard.dart';
import 'package:pcbuilder.crawler/alternate/parsers/alternateParseMemory.dart';
import "package:pcbuilder.crawler/utils.dart";
import "package:pcbuilder.crawler/model/shop.dart";
import 'dart:convert';
import 'dart:io';
import 'dart:async';

class Crawlternate {

  static Future crawlAlternate() async {
    try {

      String json;
      postRequest(getBackendServerURL()+"/shop/create", new JsonEncoder.withIndent("  ").convert(new Shop("Alternate", "https://www.alternate.nl", "https://www.alternate.nl/pix/header/logo/slogan/alternate.png")));

      // MEM //
      List memoryUnits = new List();
      List memoryUnitsTmp = new List();
      memoryUnitsTmp = await Crawler.crawl("https://www.alternate.nl/Geheugen/DDR4", new AlternateMemoryParser(), referrer: "https://www.alternate.nl/Geheugen/DDR4", /*cookies:cookies*/);
      memoryUnits.addAll(memoryUnitsTmp);
      memoryUnitsTmp = await Crawler.crawl("https://www.alternate.nl/Geheugen/DDR3", new AlternateMemoryParser(), referrer: "https://www.alternate.nl/Geheugen/DDR3", /*cookies:cookies*/);
      memoryUnits.addAll(memoryUnitsTmp);
      memoryUnitsTmp = await Crawler.crawl("https://www.alternate.nl/Geheugen/DDR2", new AlternateMemoryParser(), referrer: "https://www.alternate.nl/Geheugen/DDR2", /*cookies:cookies*/);
      memoryUnits.addAll(memoryUnitsTmp);
      memoryUnitsTmp = await Crawler.crawl("https://www.alternate.nl/Geheugen/DDR", new AlternateMemoryParser(), referrer: "https://www.alternate.nl/Geheugen/DDR", /*cookies:cookies*/);
      memoryUnits.addAll(memoryUnitsTmp);
      memoryUnitsTmp = await Crawler.crawl("https://www.alternate.nl/Geheugen/SDRAM", new AlternateMemoryParser(), referrer: "https://www.alternate.nl/Geheugen/SDRAM", /*cookies:cookies*/);
      memoryUnits.addAll(memoryUnitsTmp);

      json = new JsonEncoder.withIndent("  ").convert(memoryUnits);
      print("We found a total of ${memoryUnits.length} memory units on alternate.nl");
      File alternateMemoryUnits = new File("alternate_memory_units.json");
      alternateMemoryUnits.writeAsStringSync(json);

      // MOTHERBOARDS //
      List motherboards = new List();
      List motherboardsTmp = new List();
      motherboardsTmp = await Crawler.crawl("https://www.alternate.nl/Moederborden/AMD", new AlternateMotherboardParser(), referrer: "https://www.alternate.nl/Moederborden/AMD", /*cookies:cookies*/);
      motherboards.addAll(motherboardsTmp);
      motherboardsTmp = await Crawler.crawl("https://www.alternate.nl/Moederborden/Intel", new AlternateMotherboardParser(), referrer: "https://www.alternate.nl/Moederborden/Intel", /*cookies:cookies*/);
      motherboards.addAll(motherboardsTmp);
      json = new JsonEncoder.withIndent("  ").convert(motherboards);
      print("We found a total of ${motherboards.length} motherboards on alternate.nl");
      File alternateIntelMotherboards = new File("alternate_intel_motherboards.json");
      alternateIntelMotherboards.writeAsStringSync(json);

      // DISK //

    } catch (e) {
      print(e);
    }
  }
}
