import "package:pcbuilder.crawler/model/product.dart";
import "package:pcbuilder.crawler/model/connector.dart";
import "package:pcbuilder.crawler/utils.dart";
import "package:pcbuilder.crawler/crawler.dart";

/// Pageworker implementation for the Informatique Case ///
class InformatiqueCaseParser implements PageWorker {

  /// Crawl the detail page of the Informatique Case ///
  parse(Document document, arguments) async {

    var rows = document.querySelectorAll("ul.novendorlogo");

    for (Element listRow in rows) {

      var productRows = listRow.querySelectorAll("li");

      for (Element productRow in productRows){

        Product disk = new Product();

        var querySelector = productRow.querySelector(".product_overlay");

        if (querySelector == null ){
          continue;
        }

        disk.url = querySelector.attributes["href"];
        var tmpName = productRow.querySelector("#title").text;

        if (tmpName != null){
          var indexOf = tmpName.indexOf(" ");
          disk.brand = tmpName.substring(0, indexOf);
          disk.name = tmpName.substring(indexOf ,tmpName.length);
        }

        disk.type = "CASE";
        disk.price = price(productRow.querySelector("#price").text);
        disk.shop = "Informatique";

        await Crawler.crawl(disk.url, new InformatiqueCaseDetailParser(), arguments: disk);
      }
    }
  }
}

/// Pageworker implementation for the Informatique Case details///
class InformatiqueCaseDetailParser implements PageWorker {

  /// Crawl the detail page of the Informatique Case ///
  parse(Document document, arguments) async {

    Product caseUnit = arguments as Product;

    caseUnit.price = price(document
        .querySelector("p.verkoopprijs")
        .text);

    var prodImgA = document.querySelector(
        "div#product-image a[data-thumbnail]");

    if (prodImgA != null) {
      caseUnit.pictureUrl = prodImgA.attributes["data-thumbnail"];
    }

    String caseConnector;
    var tables = document.querySelectorAll("table#details");

    for (var table in tables) {

      var rows = table.querySelectorAll("tr");

      for (var row in rows) {

        var label = row.querySelector("strong");

        if (label == null) {
          continue;
        } else if (label.text == "EAN code") {
          caseUnit.ean = row
              .querySelector("td:last-child")
              .text;
        } else if (label.text == "Fabrikantcode") {
          caseUnit.mpn = row
              .querySelector("tr:last-child span")
              .text;
        } else if (label.text == "Formfactor") {
          caseConnector = row
              .querySelector("td:last-child")
              .text;
        }
      }
    }

    caseUnit.connectors.add(new Connector(caseConnector, "CASE"));

    await postProduct(caseUnit);
    await sleepRnd();
  }
}