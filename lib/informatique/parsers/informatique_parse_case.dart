import "package:pcbuilder.crawler/model/product.dart";
import "package:pcbuilder.crawler/model/connector.dart";
import "package:pcbuilder.crawler/utils.dart";
import "package:pcbuilder.crawler/crawler.dart";
import 'package:pcbuilder.crawler/interface/pageworker.dart';
import "package:pcbuilder.crawler/model/metrics.dart";

/// Pageworker implementation for the Informatique Case
class InformatiqueCaseParser implements PageWorker {
  Metrics metrics;
  InformatiqueCaseParser(Metrics metrics) {
    this.metrics = metrics;
  }

  /// Crawl the detail page of the Informatique Case
  parse(Document document, arguments) async {
    var rows = document.querySelectorAll("ul.novendorlogo");

    for (Element listRow in rows) {
      var productRows = listRow.querySelectorAll("li");

      for (Element productRow in productRows) {
        metrics.caseParserTime.start();

        Product computerCase = new Product();

        var querySelector = productRow.querySelector(".product_overlay");

        if (querySelector == null) {
          continue;
        }

        computerCase.name = removeTip(productRow.querySelector("#title").text);
        computerCase.url = querySelector.attributes["href"];
        computerCase.type = "CASE";
        computerCase.shop = "Informatique";

        await Crawler.crawl(
            computerCase.url, new InformatiqueCaseDetailParser(metrics),
            arguments: computerCase);
      }
    }
  }
}

/// Pageworker implementation for the Informatique Case details
class InformatiqueCaseDetailParser implements PageWorker {
  Metrics metrics;
  InformatiqueCaseDetailParser(Metrics metrics) {
    this.metrics = metrics;
  }

  /// Crawl the detail page of the Informatique Case
  parse(Document document, arguments) async {
    Product computerCase = arguments as Product;

    computerCase.brand = document.querySelector("span[itemprop='brand']").text;
    computerCase.price = price(document.querySelector("p.verkoopprijs").text);

    var prodImgA =
        document.querySelector("div#product-image a[data-thumbnail]");
    if (prodImgA != null) {
      computerCase.pictureUrl = prodImgA.attributes["data-thumbnail"];
    }

    String caseConnector = null;
    var tables = document.querySelectorAll("table#details");

    for (var table in tables) {
      var rows = table.querySelectorAll("tr");

      for (var row in rows) {
        var label = row.querySelector("strong");

        if (label == null) {
          continue;
        } else if (label.text == "EAN code") {
          computerCase.ean = row.querySelector("td:last-child").text;
        } else if (label.text == "Fabrikantcode") {
          computerCase.mpn = row.querySelector("tr:last-child span").text;
        } else if (label.text == "Formfactor" || label.text == "FormFactor") {
          if (row.querySelector("td:last-child") != null) {
            caseConnector = row.querySelector("td:last-child").text;
          }
        }
      }
    }

    if (caseConnector != null) {
      computerCase.connectors.add(new Connector(caseConnector.trim(), "CASE"));
    }

    metrics.caseParserTime.stop();

    metrics.caseBackendTime.start();
    await postProduct(computerCase);
    metrics.caseBackendTime.stop();
    metrics.caseCount++;
  }
}
