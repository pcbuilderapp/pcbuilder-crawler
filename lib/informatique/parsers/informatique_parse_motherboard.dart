import "package:pcbuilder.crawler/model/product.dart";
import "package:pcbuilder.crawler/model/connector.dart";
import "package:pcbuilder.crawler/utils.dart";
import "package:pcbuilder.crawler/urlcrawler.dart";
import 'package:pcbuilder.crawler/interface/pageworker.dart';
import "package:pcbuilder.crawler/model/metrics.dart";

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

      motherboard.name = removeTip(listRow
          .querySelector("a")
          .text
          .trim());
      motherboard.url = listRow
          .querySelector("a")
          .attributes["href"];
      motherboard.type = "MOTHERBOARD";
      motherboard.shop = "Informatique";

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
                row.querySelector("td:last-child").text.trim(), "CASE"));
            motherboard.connectors.add(new Connector("ATX", "PSU"));
          }
        } else if (label.text == "Chipset") {
          if (row.querySelector("td:last-child") != null) {
            motherboard.connectors.add(new Connector(
                row.querySelector("td:last-child").text.trim(), "CPU"));
          }
        } else if (label.text == "Fysieke PCI-E x16 sloten") {
          if (row.querySelector("td:last-child") != null) {
            motherboard.connectors.add(new Connector("PCIe", "GPU"));
          }
        } else if (label.text == "Type geheugen" ||
            label.text == "Geheugen type") {
          if (row.querySelector("td:last-child") != null) {
            motherboard.connectors.add(new Connector(
                row.querySelector("td:last-child").text.trim(), "MEMORY"));
          }
        } else if (label.text == "SATA 3 aansluitingen") {
          if (row.querySelector("td:last-child") != null) {
            motherboard.connectors.add(new Connector("SATA", "STORAGE"));
          }
        } else if (label.text == "M.2 sloten") {
          motherboard.connectors.add(new Connector("M.2", "STORAGE"));
        } else if (label.text == "Fysieke PCI-E x1 sloten") {
          motherboard.connectors.add(new Connector("PCIe", "STORAGE"));
        } else if (label.text == "mSATA aansluitingen") {
          motherboard.connectors.add(new Connector("mSATA", "STORAGE"));
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
