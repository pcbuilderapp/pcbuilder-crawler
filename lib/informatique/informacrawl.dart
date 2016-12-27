import 'package:pcbuilder.crawler/crawler.dart';
import 'package:pcbuilder.crawler/informatique/parsers/informatique_parse_motherboard.dart';
import 'package:pcbuilder.crawler/informatique/parsers/informatique_parse_memory.dart';
import 'package:pcbuilder.crawler/informatique/parsers/informatique_parse_case.dart';
import 'package:pcbuilder.crawler/informatique/parsers/informatique_parse_processor.dart';
import 'package:pcbuilder.crawler/informatique/parsers/informatique_parse_videocard.dart';
import 'package:pcbuilder.crawler/informatique/parsers/informatique_parse_disk.dart';
import "package:pcbuilder.crawler/utils.dart";
import "package:pcbuilder.crawler/model/shop.dart";
import 'dart:convert';
import 'dart:io';
import 'dart:async';

class Informacrawl {

  static Future crawlInformatique() async {
    try {

      String json;
      postRequest(getBackendServerURL()+"/shop/create", new JsonEncoder.withIndent("  ").convert(new Shop("Informatique", "www.informatique.nl", "")));

      // DISK //
      List disks = new List();
      List disksTmp = new List();
      disksTmp = await Crawler.crawl("", new InformatiqueDiskParser());
      disks.addAll(disksTmp);
      json = new JsonEncoder.withIndent("  ").convert(disks);
      print("We found a total of ${disks.length} Disks on informatique.nl");
      File informatiqueDisk = new File("informatique_disks.json");
      informatiqueDisk.writeAsStringSync(json);

      // MEMORY //
      List memoryUnits = new List();
      List memoryUnitsTmp = new List();
      memoryUnitsTmp = await Crawler.crawl("", new InformatiqueMemoryParser());
      memoryUnits.addAll(memoryUnitsTmp);
      json = new JsonEncoder.withIndent("  ").convert(memoryUnits);
      print("We found a total of ${memoryUnits.length} Memory Units on informatique.nl");
      File informatiqueMemoryUnits = new File("informatique_memory_units.json");
      informatiqueMemoryUnits.writeAsStringSync(json);

      // MOTHERBOARDS //
      List motherboards = new List();
      List motherboardsTmp = new List();
      motherboardsTmp = await Crawler.crawl("", new InformatiqueMotherboardParser());
      motherboards.addAll(motherboardsTmp);
      json = new JsonEncoder.withIndent("  ").convert(motherboards);
      print("We found a total of ${motherboards.length} Motherboards on informatique.nl");
      File informatiqueIntelMotherboards = new File("informatique_motherboards.json");
      informatiqueIntelMotherboards.writeAsStringSync(json);

      // GPU //
      List videocards = new List();
      List videocardsTmp = new List();
      videocardsTmp = await Crawler.crawl("", new InformatiqueVideoCardParser());
      videocards.addAll(videocardsTmp);
      json = new JsonEncoder.withIndent("  ").convert(videocards);
      print("We found a total of ${videocards.length} Video Cards on informatique.nl");
      File informatiqueVideocards = new File("informatique_videocards.json");
      informatiqueVideocards.writeAsStringSync(json);

      // CASING //
      List pcCases = new List();
      List pcCasesTmp = new List();
      pcCasesTmp = await Crawler.crawl("", new InformatiqueCaseParser());
      pcCases.addAll(pcCasesTmp);
      json = new JsonEncoder.withIndent("  ").convert(pcCases);
      print("We found a total of ${pcCases.length} Cases on informatique.nl");
      File informatiquePcCases = new File("informatique_pc_cases.json");
      informatiquePcCases.writeAsStringSync(json);

      // CPU //
      List processors = new List();
      List processorsTmp = new List();
      //intell
      processorsTmp = await Crawler.crawl("http://www.informatique.nl/?m=usl&g=611&view=6&&sort=pop&pl=500", new InformatiqueProcessorParser(), arguments: "Intel");
      processors.addAll(processorsTmp);
      //amd
      processorsTmp = await Crawler.crawl("http://www.informatique.nl/?m=usl&g=218&view=6&&sort=pop&pl=500", new InformatiqueProcessorParser(), arguments: "AMD");
      processors.addAll(processorsTmp);
      json = new JsonEncoder.withIndent("  ").convert(processors);
      print("We found a total of ${processors.length} Processors on informatique.nl");
      File informatiqueCpu = new File("informatique_processors.json");
      informatiqueCpu.writeAsStringSync(json);

    } catch (e) {
      print(e);
    }
  }
}