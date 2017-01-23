import 'package:pcbuilder.crawler/configuration.dart';
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

      bool activated = await isCrawlerActivated(alternateName);

      if (!activated) {
        print("Crawler " + alternateName + " won't run because it has been deactivated.");
        return;
      } else {
        print("Crawler " + alternateName + " launching...");
      }

      Metrics metrics = new Metrics();
      metrics.shop = alternateName;
      metrics.totalTime.start();

      createShop(alternateName, alternateUrl);

      await UrlCrawler.crawlComponent(
          alternateProcessorUrls, new AlternateProcessorParser(metrics));
      await UrlCrawler.crawlComponent(
          alternateDiskUrls, new AlternateStorageParser(metrics));
      await UrlCrawler.crawlComponent(alternatePowerSupplyUnitUrls,
          new AlternatePowerSupplyUnitParser(metrics));
      await UrlCrawler.crawlComponent(
          alternateMemoryUrls, new AlternateMemoryParser(metrics));
      await UrlCrawler.crawlComponent(
          alternateMotherboardUrls, new AlternateMotherboardParser(metrics));
      await UrlCrawler.crawlComponent(
          alternateVideocardUrls, new AlternateVideoCardParser(metrics));
      await UrlCrawler.crawlComponent(
          alternateCaseUrls, new AlternateCaseParser(metrics));

      metrics.totalTime.stop();
      metrics.printMetrics();

    } catch (e) {
      print(e);
    }
  }
}
