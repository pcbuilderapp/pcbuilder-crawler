import "package:pcbuilder.crawler/model/product.dart";
import "package:pcbuilder.crawler/model/connector.dart";
import "package:pcbuilder.crawler/utils.dart";
import "package:pcbuilder.crawler/urlcrawler.dart";
import 'package:pcbuilder.crawler/interface/pageworker.dart';
import "package:pcbuilder.crawler/model/metrics.dart";

class InformatiqueStorageParser implements PageWorker {
  Metrics metrics;
  InformatiqueStorageParser(Metrics metrics) {
    this.metrics = metrics;
  }

  parse(Document document, arguments) async {
    var rows = document.querySelectorAll("div#title");

    for (Element listRow in rows) {
        metrics.storageParserTime.start();

        Product storage = new Product();

        storage.name = removeTip(listRow.querySelector("a").text.trim());
        storage.url = listRow.querySelector("a").attributes["href"];
        storage.type = "STORAGE";
        storage.shop = "Informatique";

        await UrlCrawler.crawlUrl(
            storage.url, new InformatiqueStorageDetailParser(metrics),
            arguments: storage);
      }
  }
}

class InformatiqueStorageDetailParser implements PageWorker {
  Metrics metrics;
  InformatiqueStorageDetailParser(Metrics metrics) {
    this.metrics = metrics;
  }

  parse(Document document, arguments) async {
    Product storage = arguments as Product;

    storage.brand = document.querySelector("span[itemprop='brand']").text;
    storage.price = price(document.querySelector("p.verkoopprijs").text);
    setProductDiscountInformatique(document, storage);

    var prodImgA =
        document.querySelector("div#product-image a[data-thumbnail]");

    if (prodImgA != null) {
      storage.pictureUrl = prodImgA.attributes["data-thumbnail"];
    }

    var tables = document.querySelectorAll("table#details");

    bool isM2 = false;
    bool isPCIe = false;
    bool isMSata = false;

    for (var table in tables) {
      var rows = table.querySelectorAll("tr");

      for (var row in rows) {
        var label = row.querySelector("strong");

        if (label == null) {
          continue;
        } else if (label.text == "EAN code") {
          storage.ean = row.querySelector("td:last-child").text;
        } else if (label.text == "Fabrikantcode") {
          storage.mpn = row.querySelector("tr:last-child span").text;
        } else if (label.text == "M.2 (SATA)") {
          if (row.querySelector("td:last-child") != null &&
              row.querySelector("td:last-child").text == "Ja") {
            isM2 = true;
          }
        } else if (label.text == "M.2 (PCIe)") {
          if (row.querySelector("td:last-child") != null &&
              row.querySelector("td:last-child").text == "Ja") {
            isM2 = true;
          }
        } else if (label.text == "PCIe") {
          if (row.querySelector("td:last-child") != null &&
              row.querySelector("td:last-child").text == "Ja") {
            isPCIe = true;
          }
        } else if (label.text == "mSATA") {
          if (row.querySelector("td:last-child") != null &&
              row.querySelector("td:last-child").text == "Ja") {
            isMSata = true;
          }
        } else if (row.querySelector("td:last-child") != null &&
            label.text == "SATA") {
          storage.connectors.add(new Connector(
              row.querySelector("td:last-child").text, "STORAGE"));
        }

        if (storage.ean != null &&
            storage.mpn != null &&
            (isMSata || isPCIe || isM2)) {
          break;
        }
      }
    }

    if (isM2) {
      storage.connectors.add(new Connector("M.2", "STORAGE"));
    } else if (isPCIe) {
      storage.connectors.add(new Connector("PCIe", "STORAGE"));
    } else if (isMSata) {
      storage.connectors.add(new Connector("mSATA", "STORAGE"));
    } else {
      storage.connectors.add(new Connector("SATA", "STORAGE"));
    }

    metrics.storageParserTime.stop();

    metrics.storageBackendTime.start();
    await postProduct(storage);
    metrics.storageBackendTime.stop();
    metrics.storageCount++;
  }
}
