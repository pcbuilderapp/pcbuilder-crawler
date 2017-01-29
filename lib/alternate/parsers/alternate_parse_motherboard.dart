import "package:pcbuilder.crawler/utils.dart";
import 'package:pcbuilder.crawler/interface/pageworker.dart';

class AlternateMotherboardParser implements PageWorker {
  Metrics metrics;

  AlternateMotherboardParser(Metrics metrics) {
    this.metrics = metrics;
  }

  parse(Document document, arguments) async {
    var rows = document.querySelectorAll("div.listRow");

    for (Element listRow in rows) {
      metrics.motherboardParserTime.start();

      Product motherboard = new Product();
      motherboard.name = listRow.querySelector("span.name").text.trim();
      motherboard.brand =
          listRow.querySelectorAll("span.name span")[0].text.trim();
      motherboard.url = config["alternateUrl"] +
          listRow.querySelector(".productLink").attributes["href"];
      motherboard.type = config["motherboardType"];
      motherboard.price = price(listRow.querySelector("span.price").text);
      setProductDiscountAlternate(listRow, motherboard);
      motherboard.shop = config["alternateName"];

      await UrlCrawler.crawlUrl(
          motherboard.url, new AlternateMotherboardDetailParser(metrics),
          arguments: motherboard);
    }
  }
}

class AlternateMotherboardDetailParser implements PageWorker {
  Metrics metrics;
  AlternateMotherboardDetailParser(Metrics metrics) {
    this.metrics = metrics;
  }

  parse(Document document, arguments) async {
    Product motherboard = arguments as Product;

    var dataFlix = document.querySelector("script[data-flix-mpn]");
    motherboard.ean = dataFlix.attributes["data-flix-ean"];
    motherboard.mpn = dataFlix.attributes["data-flix-mpn"];
    var picUrl =
        document.querySelector("span.picture").querySelector("img[src]");
    motherboard.pictureUrl =
        config["alternateUrl"] + picUrl.attributes["src"];

    var techDataTableElements =
        document.querySelectorAll("div.techData table tr");

    for (int i = 0; i < techDataTableElements.length; i++) {
      String techDataOptional = "";
      String techDataLabel = "";
      if (techDataTableElements[i].querySelector("td.c1") != null) {
        techDataLabel =
            techDataTableElements[i].querySelector("td.c1").text.trim();
      }

      String techData = "";
      if (techDataTableElements[i].querySelector("td.c4") != null) {
        techData = techDataTableElements[i].querySelector("td.c4").text.trim();
      }

      if (techDataTableElements[i].querySelector("td.c2") != null) {
        techDataOptional =
            techDataTableElements[i].querySelector("td.c2").text.trim();
      }

      if (techDataLabel == "Socket") {
        motherboard.connectors.add(new Connector(techData, config["processorType"]));
      } else if (techDataLabel == "Inbouwsloten") {
        if (techData.endsWith("x16")) {
          motherboard.connectors.add(new Connector(techData, config["graphicsCardType"]));
        }
      } else if (techData.endsWith("x1") || techData.endsWith("x2")) {
        if (techData.contains("PCIe")) {
          motherboard.connectors.add(new Connector("PCIe", config["storageType"]));
        }
      } else if (techDataLabel == "Formfactor" ||
          techDataLabel == "FormFactor") {
        if (techData != null) {
          motherboard.connectors.add(new Connector(techData.trim(), config["computerCaseType"]));
          motherboard.connectors.add(new Connector("ATX", config["powerSupplyUnitType"]));
        }
      } else if (techDataOptional == "Ondersteunde standaarden") {
        if (techData != null) {
          motherboard.connectors.add(new Connector(techData.trim(), config["memoryType"]));
        }
      } else if (techDataOptional == "SATA") {
        motherboard.connectors.add(new Connector(techDataOptional, config["storageType"]));
      } else if (techDataOptional == "M.2") {
        motherboard.connectors.add(new Connector(techDataOptional, config["storageType"]));
      } else if (techDataOptional == "mSATA") {
        motherboard.connectors.add(new Connector(techDataOptional, config["storageType"]));
      }
    }

    metrics.motherboardParserTime.stop();

    metrics.motherboardBackendTime.start();
    await postProduct(motherboard);
    metrics.motherboardBackendTime.stop();
    metrics.motherboardCount++;
  }
}
