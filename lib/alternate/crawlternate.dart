import 'package:pcbuilder.crawler/crawler.dart';
import 'package:pcbuilder.crawler/alternate/parsers/alternate_parse_motherboard.dart';
import 'package:pcbuilder.crawler/alternate/parsers/alternate_parse_memory.dart';
import 'package:pcbuilder.crawler/alternate/parsers/alternate_parse_case.dart';
import 'package:pcbuilder.crawler/alternate/parsers/alternate_parse_processor.dart';
import 'package:pcbuilder.crawler/alternate/parsers/alternate_parse_videocard.dart';
import 'package:pcbuilder.crawler/alternate/parsers/alternate_parse_disk.dart';
import 'package:pcbuilder.crawler/alternate/parsers/alternate_parse_power_supply_unit.dart';
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

      // PSU //
      List psu = new List();
      List psuTmp = new List();
      psuTmp = await Crawler.crawl("https://www.alternate.nl/Hardware-Componenten-Voedingen-Alle-voedingen/html/listings/11604?size=500", new AlternatePowerSupplyUnitParser());
      psu.addAll(psuTmp);
      json = new JsonEncoder.withIndent("  ").convert(psu);
      print("We found a total of ${psu.length} Cases on alternate.nl");
      File alternatePsu = new File("alternate_psu.json");
      alternatePsu.writeAsStringSync(json);

      // DISK //
      List disks = new List();
      List disksTmp = new List();
      disksTmp = await Crawler.crawl("https://www.alternate.nl/Hardware/html/listings/1472811138409?size=500", new AlternateDiskParser());
      disks.addAll(disksTmp);
      disksTmp = await Crawler.crawl("https://www.alternate.nl/Harde-schijven-intern/SATA-2-5-inch?size=500", new AlternateDiskParser());
      disks.addAll(disksTmp);
      disksTmp = await Crawler.crawl("https://www.alternate.nl/Harde-schijven-intern/SATA-3-5-inch?size=500", new AlternateDiskParser());
      disks.addAll(disksTmp);
      disksTmp = await Crawler.crawl("https://www.alternate.nl/Harde-schijven-intern/Hybride?size=500", new AlternateDiskParser());
      disks.addAll(disksTmp);
      json = new JsonEncoder.withIndent("  ").convert(disks);
      print("We found a total of ${disks.length} Disks on alternate.nl");
      File alternateDisk = new File("alternate_disks.json");
      alternateDisk.writeAsStringSync(json);

      // MEMORY //
      List memoryUnits = new List();
      List memoryUnitsTmp = new List();
      memoryUnitsTmp = await Crawler.crawl("https://www.alternate.nl/Geheugen/DDR4?size=500", new AlternateMemoryParser());
      memoryUnits.addAll(memoryUnitsTmp);
      memoryUnitsTmp = await Crawler.crawl("https://www.alternate.nl/Geheugen/DDR3?size=500", new AlternateMemoryParser());
      memoryUnits.addAll(memoryUnitsTmp);
      memoryUnitsTmp = await Crawler.crawl("https://www.alternate.nl/Geheugen/DDR2?size=500", new AlternateMemoryParser());
      memoryUnits.addAll(memoryUnitsTmp);
      memoryUnitsTmp = await Crawler.crawl("https://www.alternate.nl/Geheugen/DDR?size=500", new AlternateMemoryParser());
      memoryUnits.addAll(memoryUnitsTmp);
      memoryUnitsTmp = await Crawler.crawl("https://www.alternate.nl/Geheugen/SDRAM?size=500", new AlternateMemoryParser());
      memoryUnits.addAll(memoryUnitsTmp);
      json = new JsonEncoder.withIndent("  ").convert(memoryUnits);
      print("We found a total of ${memoryUnits.length} Memory Units on alternate.nl");
      File alternateMemoryUnits = new File("alternate_memory_units.json");
      alternateMemoryUnits.writeAsStringSync(json);

      // MOTHERBOARDS //
      List motherboards = new List();
      List motherboardsTmp = new List();
      motherboardsTmp = await Crawler.crawl("https://www.alternate.nl/Moederborden/AMD?size=500", new AlternateMotherboardParser());
      motherboards.addAll(motherboardsTmp);
      motherboardsTmp = await Crawler.crawl("https://www.alternate.nl/Moederborden/Intel?size=500", new AlternateMotherboardParser());
      motherboards.addAll(motherboardsTmp);
      json = new JsonEncoder.withIndent("  ").convert(motherboards);
      print("We found a total of ${motherboards.length} Motherboards on alternate.nl");
      File alternateIntelMotherboards = new File("alternate_motherboards.json");
      alternateIntelMotherboards.writeAsStringSync(json);

      // GPU //
      List videocards = new List();
      List videocardsTmp = new List();
      videocardsTmp = await Crawler.crawl("https://www.alternate.nl/Grafische-kaarten/NVIDIA-GeForce?size=500", new AlternateVideoCardParser());
      videocards.addAll(videocardsTmp);
      videocardsTmp = await Crawler.crawl("https://www.alternate.nl/Grafische-kaarten/AMD-Radeon?size=500", new AlternateVideoCardParser());
      videocards.addAll(videocardsTmp);
      json = new JsonEncoder.withIndent("  ").convert(videocards);
      print("We found a total of ${videocards.length} Video Cards on alternate.nl");
      File alternateVideocards = new File("alternate_videocards.json");
      alternateVideocards.writeAsStringSync(json);

      // CASING //
      List pcCases = new List();
      List pcCasesTmp = new List();
      pcCasesTmp = await Crawler.crawl("https://www.alternate.nl/Behuizingen/Alle-behuizingen?size=500", new AlternateCaseParser());
      pcCases.addAll(pcCasesTmp);
      json = new JsonEncoder.withIndent("  ").convert(pcCases);
      print("We found a total of ${pcCases.length} Cases on alternate.nl");
      File alternatePcCases = new File("alternate_pc_cases.json");
      alternatePcCases.writeAsStringSync(json);

      // CPU //
      List processors = new List();
      List processorsTmp = new List();
      processorsTmp = await Crawler.crawl("https://www.alternate.nl/Processoren/Desktop/Alle-processoren?size=500", new AlternateProcessorParser());
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
