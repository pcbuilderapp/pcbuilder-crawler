import 'package:pcbuilder.crawler/config.dart';
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

      if (! await isCrawlerActivated(config["informatiqueName"])) return;

      Metrics metrics = new Metrics();
      metrics.shop = config["informatiqueName"];
      metrics.totalTime.start();

      createShop(config["informatiqueName"], config["informatiqueUrl"]);

      await UrlCrawler.crawlComponent(
          config["informatiqueProcessorUrls"], new InformatiqueProcessorParser(metrics));
      await UrlCrawler.crawlComponent(
          config["informatiqueStorageUrls"], new InformatiqueStorageParser(metrics));
      await UrlCrawler.crawlComponent(
          config["informatiquePowerSupplyUnitUrls"], new InformatiquePowerSupplyUnitParser(metrics));
      await UrlCrawler.crawlComponent(
          config["informatiqueMemoryUrls"], new InformatiqueMemoryParser(metrics));
      await UrlCrawler.crawlComponent(
          config["informatiqueMotherboardUrls"], new InformatiqueMotherboardParser(metrics));
      await UrlCrawler.crawlComponent(
          config["informatiqueVideocardUrls"], new InformatiqueVideoCardParser(metrics));
      await UrlCrawler.crawlComponent(
          config["informatiqueCaseUrls"], new InformatiqueCaseParser(metrics));

      metrics.totalTime.stop();
      metrics.printMetrics();

    } catch (e) {
      print(e);
    }
  }
}
