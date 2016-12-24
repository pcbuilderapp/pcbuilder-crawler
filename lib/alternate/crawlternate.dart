import 'package:pcbuilder.crawler/crawler.dart';
import 'package:pcbuilder.crawler/alternate/parsers/alternateParseMotherboard.dart';
import 'package:pcbuilder.crawler/alternate/parsers/alternateParseMemory.dart';
import 'package:pcbuilder.crawler/alternate/parsers/alternateParseCase.dart';
import 'package:pcbuilder.crawler/alternate/parsers/alternateParseProcessor.dart';
import 'package:pcbuilder.crawler/alternate/parsers/alternateParseVideoCard.dart';
import 'package:pcbuilder.crawler/alternate/parsers/alternateParseDisks.dart';
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

      // DISK //
      List disks = new List();
      List disksTmp = new List();
      disksTmp = await Crawler.crawl("https://www.alternate.nl/Hardware/html/listings/1472811138409?size=500", new AlternateDiskParser(), referrer: "https://www.alternate.nl", /*cookies:cookies*/);
      disks.addAll(disksTmp);
      disksTmp = await Crawler.crawl("https://www.alternate.nl/Harde-schijven-intern/SATA-2-5-inch?size=500", new AlternateDiskParser(), referrer: "https://www.alternate.nl", /*cookies:cookies*/);
      disks.addAll(disksTmp);
      disksTmp = await Crawler.crawl("https://www.alternate.nl/Harde-schijven-intern/SATA-3-5-inch?size=500", new AlternateDiskParser(), referrer: "https://www.alternate.nl", /*cookies:cookies*/);
      disks.addAll(disksTmp);
      disksTmp = await Crawler.crawl("https://www.alternate.nl/Harde-schijven-intern/Hybride?size=500", new AlternateDiskParser(), referrer: "https://www.alternate.nl", /*cookies:cookies*/);
      disks.addAll(disksTmp);
      json = new JsonEncoder.withIndent("  ").convert(disks);
      print("We found a total of ${disks.length} Disks on alternate.nl");
      File alternateDisk = new File("alternate_disks.json");
      alternateDisk.writeAsStringSync(json);

      // MEMORY //
      List memoryUnits = new List();
      List memoryUnitsTmp = new List();
      memoryUnitsTmp = await Crawler.crawl("https://www.alternate.nl/Geheugen/DDR4?size=500", new AlternateMemoryParser(), referrer: "https://www.alternate.nl/Geheugen/DDR4", /*cookies:cookies*/);
      memoryUnits.addAll(memoryUnitsTmp);
      memoryUnitsTmp = await Crawler.crawl("https://www.alternate.nl/Geheugen/DDR3?size=500", new AlternateMemoryParser(), referrer: "https://www.alternate.nl/Geheugen/DDR3", /*cookies:cookies*/);
      memoryUnits.addAll(memoryUnitsTmp);
      memoryUnitsTmp = await Crawler.crawl("https://www.alternate.nl/Geheugen/DDR2?size=500", new AlternateMemoryParser(), referrer: "https://www.alternate.nl/Geheugen/DDR2", /*cookies:cookies*/);
      memoryUnits.addAll(memoryUnitsTmp);
      memoryUnitsTmp = await Crawler.crawl("https://www.alternate.nl/Geheugen/DDR?size=500", new AlternateMemoryParser(), referrer: "https://www.alternate.nl/Geheugen/DDR", /*cookies:cookies*/);
      memoryUnits.addAll(memoryUnitsTmp);
      memoryUnitsTmp = await Crawler.crawl("https://www.alternate.nl/Geheugen/SDRAM?size=500", new AlternateMemoryParser(), referrer: "https://www.alternate.nl/Geheugen/SDRAM", /*cookies:cookies*/);
      memoryUnits.addAll(memoryUnitsTmp);
      json = new JsonEncoder.withIndent("  ").convert(memoryUnits);
      print("We found a total of ${memoryUnits.length} Memory Units on alternate.nl");
      File alternateMemoryUnits = new File("alternate_memory_units.json");
      alternateMemoryUnits.writeAsStringSync(json);

      // MOTHERBOARDS //
      List motherboards = new List();
      List motherboardsTmp = new List();
      motherboardsTmp = await Crawler.crawl("https://www.alternate.nl/Moederborden/AMD?size=500", new AlternateMotherboardParser(), referrer: "https://www.alternate.nl/Moederborden/AMD", /*cookies:cookies*/);
      motherboards.addAll(motherboardsTmp);
      motherboardsTmp = await Crawler.crawl("https://www.alternate.nl/Moederborden/Intel?size=500", new AlternateMotherboardParser(), referrer: "https://www.alternate.nl/Moederborden/Intel", /*cookies:cookies*/);
      motherboards.addAll(motherboardsTmp);
      json = new JsonEncoder.withIndent("  ").convert(motherboards);
      print("We found a total of ${motherboards.length} Motherboards on alternate.nl");
      File alternateIntelMotherboards = new File("alternate_motherboards.json");
      alternateIntelMotherboards.writeAsStringSync(json);

      // GPU //
      List videocards = new List();
      List videocardsTmp = new List();
      videocardsTmp = await Crawler.crawl("https://www.alternate.nl/Grafische-kaarten/NVIDIA-GeForce?size=500", new AlternateVideoCardParser(), referrer: "https://www.alternate.nl/Processoren/Desktop/Alle-processoren", /*cookies:cookies*/);
      videocards.addAll(videocardsTmp);
      videocardsTmp = await Crawler.crawl("https://www.alternate.nl/Grafische-kaarten/AMD-Radeon?size=500", new AlternateVideoCardParser(), referrer: "https://www.alternate.nl/Processoren/Desktop/Alle-processoren", /*cookies:cookies*/);
      videocards.addAll(videocardsTmp);
      json = new JsonEncoder.withIndent("  ").convert(videocards);
      print("We found a total of ${videocards.length} Video Cards on alternate.nl");
      File alternateVideocards = new File("alternate_videocards.json");
      alternateVideocards.writeAsStringSync(json);

      // CASING //
      List pcCases = new List();
      List pcCasesTmp = new List();
      pcCasesTmp = await Crawler.crawl("https://www.alternate.nl/Behuizingen/Alle-behuizingen?size=500", new AlternateCaseParser(), referrer: "https://www.alternate.nl/Behuizingen/Alle-behuizingen", /*cookies:cookies*/);
      pcCases.addAll(pcCasesTmp);
      json = new JsonEncoder.withIndent("  ").convert(pcCases);
      print("We found a total of ${pcCases.length} Cases on alternate.nl");
      File alternatePcCases = new File("alternate_pc_cases.json");
      alternatePcCases.writeAsStringSync(json);

      // CPU //
      List processors = new List();
      List processorsTmp = new List();
      processorsTmp = await Crawler.crawl("https://www.alternate.nl/Processoren/Desktop/Alle-processoren?size=500", new AlternateProcessorParser(), referrer: "https://www.alternate.nl/Processoren/Desktop/Alle-processoren", /*cookies:cookies*/);
      processors.addAll(processorsTmp);
      json = new JsonEncoder.withIndent("  ").convert(processors);
      print("We found a total of ${processors.length} Processors on alternate.nl");
      File alternateCpu = new File("alternate_processors.json");
      alternateCpu.writeAsStringSync(json);

    } catch (e) {
      print(e);
    }
  }
}
