import "package:pcbuilder.crawler/utils.dart";
import 'package:pcbuilder.crawler/interface/pageworker.dart';

/// Pageworker implementation for the Informatique Case
class InformatiqueCaseParser implements PageWorker {
  Metrics metrics;
  InformatiqueCaseParser(Metrics metrics) {
    this.metrics = metrics;
  }

  /// Crawl the detail page of the Informatique Case
  parse(Document document, arguments) async {
    var rows = document.querySelectorAll("div#title");

    for (Element listRow in rows) {
      metrics.caseParserTime.start();

      Product computerCase = new Product();

      computerCase.name = removeTip(listRow.querySelector("a").text.trim());
      computerCase.url = listRow.querySelector("a").attributes["href"];
      computerCase.type = config["computerCaseType"];
      computerCase.shop = config["informatiqueName"];

      await UrlCrawler.crawlUrl(
          computerCase.url, new InformatiqueCaseDetailParser(metrics),
          arguments: computerCase);
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
    setProductDiscountInformatique(document, computerCase);

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

    extendCaseType(caseConnector, computerCase);

    metrics.caseParserTime.stop();

    metrics.caseBackendTime.start();
    await postProduct(computerCase);
    metrics.caseBackendTime.stop();
    metrics.caseCount++;
  }

}
