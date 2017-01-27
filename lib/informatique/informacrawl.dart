import 'package:pcbuilder.crawler/configuration.dart';
import 'package:pcbuilder.crawler/urlcrawler.dart';
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
  crawlShop() async {
    try {

      bool activated = await isCrawlerActivated(informatiqueName);

      if (!activated) {
        print("Crawler " + informatiqueName + " won't run because it has been deactivated.");
        return;
      } else {
        print("Crawler " + informatiqueName + " launching...");
      }

      Metrics metrics = new Metrics();
      metrics.shop = informatiqueName;
      metrics.totalTime.start();

      createShop(informatiqueName, informatiqueUrl);

      await UrlCrawler.crawlComponent(
          informatiqueProcessorUrls, new InformatiqueProcessorParser(metrics));
      await UrlCrawler.crawlComponent(
          informatiqueDiskUrls, new InformatiqueStorageParser(metrics));
      await UrlCrawler.crawlComponent(informatiquePowerSupplyUnitUrls,
          new InformatiquePowerSupplyUnitParser(metrics));
      await UrlCrawler.crawlComponent(
          informatiqueMemoryUrls, new InformatiqueMemoryParser(metrics));
      await UrlCrawler.crawlComponent(informatiqueMotherboardUrls,
          new InformatiqueMotherboardParser(metrics));
      await UrlCrawler.crawlComponent(
          informatiqueVideocardUrls, new InformatiqueVideoCardParser(metrics));
      await UrlCrawler.crawlComponent(
          informatiqueCaseUrls, new InformatiqueCaseParser(metrics));

      metrics.totalTime.stop();
      metrics.printMetrics();

    } catch (e) {
      print(e);
    }
  }
}
