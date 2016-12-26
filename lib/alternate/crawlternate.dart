import 'package:pcbuilder.crawler/crawler.dart';
import 'package:pcbuilder.crawler/alternate/parsers/alternateParseMotherboard.dart';
import 'package:pcbuilder.crawler/alternate/parsers/alternateParseMemory.dart';
import 'package:pcbuilder.crawler/alternate/parsers/alternateParseCase.dart';
import 'package:pcbuilder.crawler/alternate/parsers/alternateParseProcessor.dart';
import 'package:pcbuilder.crawler/alternate/parsers/alternateParsePowerSupplyUnit.dart';
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

      // Case //
      List pcCase = new List();
      List pcCaseTmp = new List();
      pcCaseTmp = await Crawler.crawl("https://www.alternate.nl/Hardware-Componenten-Behuizingen-Alle-behuizingen/html/listings/2436?lk=9309&size=500#listingResult", new AlternateCaseParser(), referrer: "https://www.alternate.nl/Behuizingen/Alle-behuizingen", /*cookies:cookies*/);
      pcCase.addAll(pcCaseTmp);
      json = new JsonEncoder.withIndent("  ").convert(pcCase);
      print("We found a total of ${pcCase.length} Cases on alternate.nl");
      File alternatePcCases = new File("alternate_pc_case.json");
      alternatePcCases.writeAsStringSync(json);

      // CPU //
      List cpu = new List();
      List cpuTmp = new List();
      cpuTmp = await Crawler.crawl("https://www.alternate.nl/Hardware-Componenten-Processoren-Desktop-Alle-processoren/html/listings/11572?lk=9487&sepid=10846&size=500&showFilter=true#listingResult", new AlternateProcessorParser(), referrer: "https://www.alternate.nl/Processoren/Desktop/Alle-processoren", /*cookies:cookies*/);
      cpu.addAll(cpuTmp);
      json = new JsonEncoder.withIndent("  ").convert(cpu);
      print("We found a total of ${cpu.length} Cases on alternate.nl");
      File alternateCpu = new File("alternate_cpu.json");
      alternateCpu.writeAsStringSync(json);

      // PSU //
      List psu = new List();
      List psuTmp = new List();
      psuTmp = await Crawler.crawl("https://www.alternate.nl/Hardware-Componenten-Voedingen-Alle-voedingen/html/listings/11604?tk=7&lk=9533&sepid=8215&size=500&showFilter=true#listingResult", new AlternatePowerSupplyUnitParser(), referrer: "https://www.alternate.nl/Voedingen", /*cookies:cookies*/);
      psu.addAll(psuTmp);
      json = new JsonEncoder.withIndent("  ").convert(psu);
      print("We found a total of ${psu.length} Cases on alternate.nl");
      File alternatePsu = new File("alternate_psu.json");
      alternatePsu.writeAsStringSync(json);

    } catch (e) {
      print(e);
    }
  }
}
