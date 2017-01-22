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
    var rows = document.querySelectorAll("div#title");

    for (Element listRow in rows) {
      metrics.storageParserTime.start();

      Product computerCase = new Product();

      computerCase.name = removeTip(listRow.querySelector("a").text.trim());
      computerCase.url = listRow.querySelector("a").attributes["href"];
      computerCase.type = "CASE";
      computerCase.shop = "Informatique";

      await Crawler.crawl(
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

    /* TODO future development, add all conector for case
     if (caseConnector != null) {
      if(caseConnector == "XL-ATX"){
        computerCase.connectors.add(new Connector("ATX", "CASE"));
        computerCase.connectors.add(new Connector("mATX", "CASE"));
        computerCase.connectors.add(new Connector("mITX", "CASE"));
        computerCase.connectors.add(new Connector("XL-ATX", "CASE"));
        computerCase.connectors.add(new Connector("E-ATX", "CASE"));
      } else if(caseConnector == "E-ATX"){
        computerCase.connectors.add(new Connector("ATX", "CASE"));
        computerCase.connectors.add(new Connector("mATX", "CASE"));
        computerCase.connectors.add(new Connector("mITX", "CASE"));
        computerCase.connectors.add(new Connector("E-ATX", "CASE"));
      } else if(caseConnector == "ATX"){
        computerCase.connectors.add(new Connector("ATX", "CASE"));
        computerCase.connectors.add(new Connector("mATX", "CASE"));
        computerCase.connectors.add(new Connector("mITX", "CASE"));
      } else if(caseConnector == "mATX"){
        computerCase.connectors.add(new Connector("mATX", "CASE"));
        computerCase.connectors.add(new Connector("mITX", "CASE"));
      }else {
        computerCase.connectors.add(new Connector(caseConnector.trim(), "CASE"));
      }


      computerCase.connectors.add(new Connector("ATX", "CASE"));
      computerCase.connectors.add(new Connector("µATX", "CASE"));
      computerCase.connectors.add(new Connector("Mini-ITX", "CASE"));
      computerCase.connectors.add(new Connector("E-ATX", "CASE"));
      computerCase.connectors.add(new Connector("XL-ATX", "CASE"));
      computerCase.connectors.add(new Connector("SSI-EEB", "CASE"));
      computerCase.connectors.add(new Connector("SSI-CEB", "CASE"));
      computerCase.connectors.add(new Connector("DTX", "CASE"));
      computerCase.connectors.add(new Connector("HPTX", "CASE"));

    }*/

    metrics.caseParserTime.stop();

    metrics.caseBackendTime.start();
    await postProduct(computerCase);
    metrics.caseBackendTime.stop();
    metrics.caseCount++;
  }
}
