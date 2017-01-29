import 'package:pcbuilder.crawler/config.dart';
import 'package:pcbuilder.crawler/urlcrawler.dart';
import "package:pcbuilder.crawler/model/metrics.dart";
import 'package:pcbuilder.crawler/interface/shopcrawler.dart';
import 'package:pcbuilder.crawler/alternate/parsers/alternate_parse_motherboard.dart';
import 'package:pcbuilder.crawler/alternate/parsers/alternate_parse_memory.dart';
import 'package:pcbuilder.crawler/alternate/parsers/alternate_parse_case.dart';
import 'package:pcbuilder.crawler/alternate/parsers/alternate_parse_processor.dart';
import 'package:pcbuilder.crawler/alternate/parsers/alternate_parse_videocard.dart';
import 'package:pcbuilder.crawler/alternate/parsers/alternate_parse_storage.dart';
import 'package:pcbuilder.crawler/alternate/parsers/alternate_parse_power_supply_unit.dart';
import "package:pcbuilder.crawler/utils.dart";

///Alternate crawling functionality///
class Crawlternate implements ShopCrawler {
  ///Crawl all components from the webshop Alternate///
  crawlShop() async {

    try {

      bool activated = await isCrawlerActivated(config["alternateName"]);

      if (!activated) {
        print("Crawler " + config["alternateName"] + " won't run because it has been deactivated.");
        return;
      } else {
        print("Crawler " + config["alternateName"] + " launching...");
      }

      Metrics metrics = new Metrics();
      metrics.shop = config["alternateName"];
      metrics.totalTime.start();

      createShop(config["alternateName"], config["alternateUrl"]);

      await UrlCrawler.crawlComponent(
          config["alternateProcessorUrls"], new AlternateProcessorParser(metrics));
      await UrlCrawler.crawlComponent(
          config["alternateStorageUrls"], new AlternateStorageParser(metrics));
      await UrlCrawler.crawlComponent(
          config["alternatePowerSupplyUnitUrls"], new AlternatePowerSupplyUnitParser(metrics));
      await UrlCrawler.crawlComponent(
          config["alternateMemoryUrls"], new AlternateMemoryParser(metrics));
      await UrlCrawler.crawlComponent(
          config["alternateMotherboardUrls"], new AlternateMotherboardParser(metrics));
      await UrlCrawler.crawlComponent(
          config["alternateVideocardUrls"], new AlternateVideoCardParser(metrics));
      await UrlCrawler.crawlComponent(
          config["alternateCaseUrls"], new AlternateCaseParser(metrics));

      metrics.totalTime.stop();
      metrics.printMetrics();

    } catch (e) {
      print(e);
    }
  }
}
