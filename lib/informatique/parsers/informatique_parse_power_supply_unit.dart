import "package:pcbuilder.crawler/model/product.dart";
import "package:pcbuilder.crawler/model/connector.dart";
import "package:pcbuilder.crawler/utils.dart";
import "package:pcbuilder.crawler/urlcrawler.dart";
import 'package:pcbuilder.crawler/interface/pageworker.dart';
import "package:pcbuilder.crawler/model/metrics.dart";

class InformatiquePowerSupplyUnitParser implements PageWorker {
  Metrics metrics;
  InformatiquePowerSupplyUnitParser(Metrics metrics) {
    this.metrics = metrics;
  }
  parse(Document document, arguments) async {
    var rows = document.querySelectorAll("div#title");

    for (Element listRow in rows) {
      metrics.powerSupplyUnitParserTime.start();

      Product powerSupplyUnit = new Product();

      powerSupplyUnit.name = removeTip(listRow.querySelector("a").text.trim());
      powerSupplyUnit.url = listRow.querySelector("a").attributes["href"];
      powerSupplyUnit.type = "PSU";
      powerSupplyUnit.shop = "Informatique";

      await UrlCrawler.crawlUrl(powerSupplyUnit.url,
          new InformatiquePowerSupplyUnitDetailParser(metrics),
          arguments: powerSupplyUnit);
    }
  }
}

class InformatiquePowerSupplyUnitDetailParser implements PageWorker {
  Metrics metrics;
  InformatiquePowerSupplyUnitDetailParser(Metrics metrics) {
    this.metrics = metrics;
  }
  parse(Document document, arguments) async {
    Product powerSupplyUnit = arguments as Product;

    powerSupplyUnit.brand =
        document.querySelector("span[itemprop='brand']").text;
    powerSupplyUnit.price =
        price(document.querySelector("p.verkoopprijs").text);

    var prodImgA =
        document.querySelector("div#product-image a[data-thumbnail]");

    if (prodImgA != null) {
      powerSupplyUnit.pictureUrl = prodImgA.attributes["data-thumbnail"];
    }

    String psuConnector = null;
    var tables = document.querySelectorAll("table#details");

    for (var table in tables) {
      var rows = table.querySelectorAll("tr");

      for (var row in rows) {
        var label = row.querySelector("strong");

        if (label == null) {
          continue;
        } else if (label.text == "EAN code") {
          powerSupplyUnit.ean = row.querySelector("td:last-child").text;
        } else if (label.text == "Fabrikantcode") {
          powerSupplyUnit.mpn = row.querySelector("tr:last-child span").text;
        } else if (label.text == "Standaard") {
          if (row.querySelector("td:last-child") != null) {
            psuConnector = row.querySelector("td:last-child").text;
          }
        }
      }
    }

    if (psuConnector != null) {
      powerSupplyUnit.connectors.add(new Connector(psuConnector.trim(), "PSU"));
    }

    metrics.powerSupplyUnitParserTime.stop();

    metrics.powerSupplyUnitBackendTime.start();
    await postProduct(powerSupplyUnit);
    metrics.powerSupplyUnitBackendTime.stop();
    metrics.powerSupplyUnitCount++;
  }
}
