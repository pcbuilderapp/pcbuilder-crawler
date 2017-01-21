import 'package:pcbuilder.crawler/configuration.dart';
import 'package:pcbuilder.crawler/crawler.dart';
import "package:pcbuilder.crawler/utils.dart";
import "package:pcbuilder.crawler/model/metrics.dart";
import 'package:pcbuilder.crawler/interface/shopcrawler.dart';
import 'package:pcbuilder.crawler/informatique/parsers/informatique_parse_motherboard.dart';
import 'package:pcbuilder.crawler/informatique/parsers/informatique_parse_memory.dart';
import 'package:pcbuilder.crawler/informatique/parsers/informatique_parse_case.dart';
import 'package:pcbuilder.crawler/informatique/parsers/informatique_parse_processor.dart';
import 'package:pcbuilder.crawler/informatique/parsers/informatique_parse_videocard.dart';
import 'package:pcbuilder.crawler/informatique/parsers/informatique_parse_storage.dart';
import 'package:pcbuilder.crawler/informatique/parsers/informatique_parse_power_supply_unit.dart';

///Informatique crawling functionality
class Informacrawl implements ShopCrawler {
  ///Crawl all components from the webshop Informatique
  crawl(Metrics metrics) async {
    try {
      metrics.shop = informatiqueName;
      metrics.totalTime.start();

      createShop(informatiqueName, informatiqueUrl);

      await Crawler.crawlComponent(
          informatiqueProcessorUrls, new InformatiqueProcessorParser(metrics));
      await Crawler.crawlComponent(
          informatiqueDiskUrls, new InformatiqueStorageParser(metrics));
      await Crawler.crawlComponent(informatiquePowerSupplyUnitUrls,
          new InformatiquePowerSupplyUnitParser(metrics));
      await Crawler.crawlComponent(
          informatiqueMemoryUrls, new InformatiqueMemoryParser(metrics));
      await Crawler.crawlComponent(informatiqueMotherboardUrls,
          new InformatiqueMotherboardParser(metrics));
      await Crawler.crawlComponent(
          informatiqueVideocardUrls, new InformatiqueVideoCardParser(metrics));
      await Crawler.crawlComponent(
          informatiqueCaseUrls, new InformatiqueCaseParser(metrics));

      metrics.totalTime.stop();
    } catch (e) {
      print(e);
    }
  }
}
