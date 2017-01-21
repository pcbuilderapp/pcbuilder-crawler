import "package:pcbuilder.crawler/model/product.dart";
import "package:pcbuilder.crawler/model/connector.dart";
import "package:pcbuilder.crawler/utils.dart";
import "package:pcbuilder.crawler/crawler.dart";
import 'package:pcbuilder.crawler/interface/pageworker.dart';
import "package:pcbuilder.crawler/model/metrics.dart";

class AlternatePowerSupplyUnitParser implements PageWorker {
  Metrics metrics;

  AlternatePowerSupplyUnitParser(Metrics metrics) {
    this.metrics = metrics;
  }

  parse(Document document, arguments) async {
    var rows = document.querySelectorAll("div.listRow");

    for (Element listRow in rows) {
      metrics.powerSupplyUnitParserTime.start();

      Product powerSupplyUnit = new Product();
      powerSupplyUnit.name = listRow.querySelector("span.name").text.trim();
      powerSupplyUnit.brand =
          listRow.querySelectorAll("span.name span")[0].text.trim();
      powerSupplyUnit.url = "https://www.alternate.nl" +
          listRow.querySelector(".productLink").attributes["href"];
      powerSupplyUnit.type = "PSU";
      powerSupplyUnit.price = price(listRow.querySelector("span.price").text);
      powerSupplyUnit.shop = "Alternate";

      await Crawler.crawl(powerSupplyUnit.url,
          new AlternatePowerSupplyUnitDetailParser(metrics),
          arguments: powerSupplyUnit);
    }
  }
}

class AlternatePowerSupplyUnitDetailParser implements PageWorker {
  Metrics metrics;

  AlternatePowerSupplyUnitDetailParser(Metrics metrics) {
    this.metrics = metrics;
  }

  parse(Document document, arguments) async {
    Product powerSupplyUnit = arguments as Product;

    var dataFlix = document.querySelector("script[data-flix-mpn]");
    powerSupplyUnit.ean = dataFlix.attributes["data-flix-ean"];
    powerSupplyUnit.mpn = dataFlix.attributes["data-flix-mpn"];
    var picUrl =
        document.querySelector("span.picture").querySelector("img[src]");
    powerSupplyUnit.pictureUrl =
        "https://www.alternate.nl" + picUrl.attributes["src"];

    String psuForm = null;
    var techDataTableElements =
        document.querySelectorAll("div.techData table tr");
    bool saveNext = false;
    bool breakMethod = false;

    for (int i = 0; i < techDataTableElements.length; i++) {
      String techDataLabel = "";
      if (techDataTableElements[i].querySelector("html td") != null) {
        techDataLabel =
            techDataTableElements[i].querySelector("html td").text.trim();
      }

      if (saveNext) {
        if (techDataTableElements[i].querySelector("html td") != null) {
          psuForm =
              techDataTableElements[i].querySelector("html td").text.trim();
          breakMethod = true;
        }
      }

      if (techDataLabel == "Bouwvorm") {
        saveNext = true;
      }

      if (breakMethod) {
        break;
      }
    }

    if (psuForm != null) {
      powerSupplyUnit.connectors.add(new Connector(psuForm, "PSU"));
    }

    metrics.powerSupplyUnitParserTime.stop();

    metrics.powerSupplyUnitBackendTime.start();
    await postProduct(powerSupplyUnit);
    metrics.powerSupplyUnitBackendTime.stop();
    metrics.powerSupplyUnitCount++;
  }
}
