import 'package:pcbuilder.crawler/configuration.dart';
import 'package:pcbuilder.crawler/crawler.dart';
import "package:pcbuilder.crawler/utils.dart";
import 'package:pcbuilder.crawler/informatique/parsers/informatique_parse_motherboard.dart';
import 'package:pcbuilder.crawler/informatique/parsers/informatique_parse_memory.dart';
import 'package:pcbuilder.crawler/informatique/parsers/informatique_parse_case.dart';
import 'package:pcbuilder.crawler/informatique/parsers/informatique_parse_processor.dart';
import 'package:pcbuilder.crawler/informatique/parsers/informatique_parse_videocard.dart';
import 'package:pcbuilder.crawler/informatique/parsers/informatique_parse_disk.dart';
import 'package:pcbuilder.crawler/informatique/parsers/informatique_parse_power_supply_unit.dart';

///Informatique crawling functionality///
class Informacrawl {

  ///Crawl all components from the webshop Informatique///
  static crawlInformatique() async {

    try {

      createShop(informatiqueName, informatiqueUrl);

      await Crawler.crawlComponent(informatiqueProcessorUrls, new InformatiqueProcessorParser());
      await Crawler.crawlComponent(informatiqueDiskUrls, new InformatiqueDiskParser());
      await Crawler.crawlComponent(informatiquePowerSupplyUnitUrls, new InformatiquePowerSupplyUnitParser());
      await Crawler.crawlComponent(informatiqueMemoryUrls, new InformatiqueMemoryParser());
      await Crawler.crawlComponent(informatiqueMotherboardUrls, new InformatiqueMotherboardParser());
      await Crawler.crawlComponent(informatiqueVideocardUrls, new InformatiqueVideoCardParser());
      await Crawler.crawlComponent(informatiqueCaseUrls, new InformatiqueCaseParser());

    } catch (e) {
      print(e);
    }
  }
}
