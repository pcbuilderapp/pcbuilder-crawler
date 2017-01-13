import "package:pcbuilder.crawler/model/product.dart";
import "package:pcbuilder.crawler/model/connector.dart";
import "package:pcbuilder.crawler/utils.dart";
import "package:pcbuilder.crawler/crawler.dart";
import 'dart:convert';

class InformatiqueCaseParser implements PageWorker {

  parse(Document document, arguments) async {

    List disks = [];
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
        if (disk.connectors.length > 0 ) {
          disks.add(disk);
        }
      }

    }
    return disks;
  }
}


class InformatiqueCaseDetailParser implements PageWorker {

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
      String productJSON = new JsonEncoder.withIndent("  ").convert(caseUnit);
      postRequest(getBackendServerURL() + "/product/add", productJSON);
      print(productJSON);
      await sleepRnd();
    }
}