import 'package:pcbuilder.crawler/configuration.dart';
import 'package:pcbuilder.crawler/crawler.dart';
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
import 'dart:async';

///Alternate crawling functionality///
class Crawlternate implements ShopCrawler {
  ///Crawl all components from the webshop Alternate///
  crawl(Metrics metrics) async {
    try {
      metrics.shop = alternateName;
      metrics.totalTime.start();

      createShop(alternateName, alternateUrl);

      await Crawler.crawlComponent(
          alternateProcessorUrls, new AlternateProcessorParser(metrics));
      await Crawler.crawlComponent(
          alternateDiskUrls, new AlternateStorageParser(metrics));
      await Crawler.crawlComponent(alternatePowerSupplyUnitUrls,
          new AlternatePowerSupplyUnitParser(metrics));
      await Crawler.crawlComponent(
          alternateMemoryUrls, new AlternateMemoryParser(metrics));
      await Crawler.crawlComponent(
          alternateMotherboardUrls, new AlternateMotherboardParser(metrics));
      await Crawler.crawlComponent(
          alternateVideocardUrls, new AlternateVideoCardParser(metrics));
      await Crawler.crawlComponent(
          alternateCaseUrls, new AlternateCaseParser(metrics));

      metrics.totalTime.stop();
    } catch (e) {
      print(e);
    }
  }
}
