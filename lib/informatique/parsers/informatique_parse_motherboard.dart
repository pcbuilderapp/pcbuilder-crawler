import "package:pcbuilder.crawler/utils.dart";
import 'package:pcbuilder.crawler/interface/pageworker.dart';

class InformatiqueMotherboardParser implements PageWorker {
  Metrics metrics;
  InformatiqueMotherboardParser(Metrics metrics) {
    this.metrics = metrics;
  }
  parse(Document document, arguments) async {
    var rows = document.querySelectorAll("div#title");

    for (Element listRow in rows) {
      metrics.motherboardParserTime.start();

      Product motherboard = new Product();
      var title = document.querySelector("title");
      motherboard.connectors.add(new Connector(title.text, config["processorType"]));

      motherboard.name = removeTip(listRow
          .querySelector("a")
          .text
          .trim());
      motherboard.url = listRow
          .querySelector("a")
          .attributes["href"];
      motherboard.type = config["motherboardType"];
      motherboard.shop = config["informatiqueName"];

      await UrlCrawler.crawlUrl(
          motherboard.url, new InformatiqueMotherboardDetailParser(metrics),
          arguments: motherboard);
    }
  }
}

class InformatiqueMotherboardDetailParser implements PageWorker {
  Metrics metrics;
  InformatiqueMotherboardDetailParser(Metrics metrics) {
    this.metrics = metrics;
  }
  parse(Document document, arguments) async {
    Product motherboard = arguments as Product;

    motherboard.brand = document.querySelector("span[itemprop='brand']").text;
    motherboard.price = price(document.querySelector("p.verkoopprijs").text);
    setProductDiscountInformatique(document, motherboard);

    var prodImgA =
        document.querySelector("div#product-image a[data-thumbnail]");

    if (prodImgA != null) {
      motherboard.pictureUrl = prodImgA.attributes["data-thumbnail"];
    }

    var tables = document.querySelectorAll("table#details");

    for (var table in tables) {
      var rows = table.querySelectorAll("tr");

      for (var row in rows) {
        var label = row.querySelector("strong");

        if (label == null) {
          continue;
        } else if (label.text == "EAN code") {
          motherboard.ean = row.querySelector("td:last-child").text;
        } else if (label.text == "Fabrikantcode") {
          motherboard.mpn = row.querySelector("tr:last-child span").text;
        } else if (label.text == "Form factor" || label.text == "Form Factor") {
          if (row.querySelector("td:last-child") != null) {
            motherboard.connectors.add(new Connector(
                row.querySelector("td:last-child").text.trim(), config["computerCaseType"]));
            motherboard.connectors.add(new Connector("ATX", config["powerSupplyUnitType"]));
          }
        } else if (label.text == "Fysieke PCI-E x16 sloten") {
          if (row.querySelector("td:last-child") != null) {
            motherboard.connectors.add(new Connector("PCIe", config["graphicsCardType"]));
          }
        } else if (label.text == "Type geheugen" ||
            label.text == "Geheugen type") {
          if (row.querySelector("td:last-child") != null) {
            motherboard.connectors.add(new Connector(
                row.querySelector("td:last-child").text.trim(), config["memoryType"]));
          }
        } else if (label.text == "SATA 3 aansluitingen") {
          if (row.querySelector("td:last-child") != null) {
            motherboard.connectors.add(new Connector("SATA", config["storageType"]));
          }
        } else if (label.text == "M.2 sloten") {
          motherboard.connectors.add(new Connector("M.2", config["storageType"]));
        } else if (label.text == "Fysieke PCI-E x1 sloten") {
          motherboard.connectors.add(new Connector("PCIe", config["storageType"]));
        } else if (label.text == "mSATA aansluitingen") {
          motherboard.connectors.add(new Connector("mSATA", config["storageType"]));
        }
      }
    }

    metrics.motherboardParserTime.stop();

    metrics.motherboardBackendTime.start();
    await postProduct(motherboard);
    metrics.motherboardBackendTime.stop();
    metrics.motherboardCount++;
  }
}
