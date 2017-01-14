import 'package:pcbuilder.crawler/configuration.dart';
import 'package:pcbuilder.crawler/crawler.dart';
import 'package:pcbuilder.crawler/alternate/parsers/alternate_parse_motherboard.dart';
import 'package:pcbuilder.crawler/alternate/parsers/alternate_parse_memory.dart';
import 'package:pcbuilder.crawler/alternate/parsers/alternate_parse_case.dart';
import 'package:pcbuilder.crawler/alternate/parsers/alternate_parse_processor.dart';
import 'package:pcbuilder.crawler/alternate/parsers/alternate_parse_videocard.dart';
import 'package:pcbuilder.crawler/alternate/parsers/alternate_parse_disk.dart';
import 'package:pcbuilder.crawler/alternate/parsers/alternate_parse_power_supply_unit.dart';
import "package:pcbuilder.crawler/utils.dart";
import 'dart:async';

///Alternate crawling functionality///
class Crawlternate {

  ///Crawl all components from the webshop Alternate///
  static Future crawlAlternate() async {

    try {

      createShop(alternateName, alternateUrl);

      await Crawler.crawlComponent(alternateProcessorUrls, new AlternateProcessorParser());
      await Crawler.crawlComponent(alternateDiskUrls, new AlternateDiskParser());
      await Crawler.crawlComponent(alternatePowerSupplyUnitUrls, new AlternatePowerSupplyUnitParser());
      await Crawler.crawlComponent(alternateMemoryUrls, new AlternateMemoryParser());
      await Crawler.crawlComponent(alternateMotherboardUrls, new AlternateMotherboardParser());
      await Crawler.crawlComponent(alternateVideocardUrls, new AlternateVideoCardParser());
      await Crawler.crawlComponent(alternateCaseUrls, new AlternateCaseParser());

    } catch (e) {
      print(e);
    }
  }
}
