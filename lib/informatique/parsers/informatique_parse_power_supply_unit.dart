import "package:pcbuilder.crawler/model/product.dart";
import "package:pcbuilder.crawler/model/connector.dart";
import "package:pcbuilder.crawler/utils.dart";
import "package:pcbuilder.crawler/crawler.dart";
import 'dart:convert';

class InformatiquePowerSupplyUnitParser implements PageWorker {

  parse(Document document, arguments) async {

    List psus = [];
    var rows = document.querySelectorAll("ul.novendorlogo");
    for (Element listRow in rows) {
      var productRows = listRow.querySelectorAll("li");
      for (Element productRow in productRows){
        Product psu = new Product();
        var querySelector = productRow.querySelector(".product_overlay");
        if (querySelector == null ){
          continue;
        }
        psu.url = querySelector.attributes["href"];
        var tmpName = productRow.querySelector("#title").text;
        if (tmpName != null){
          var indexOf = tmpName.indexOf(" ");
          psu.brand = tmpName.substring(0, indexOf);
          psu.name = tmpName.substring(indexOf ,tmpName.length);
        }
        psu.type = "PSU";
        psu.price = price(productRow.querySelector("#price").text);
        psu.shop = "Informatique";
        await Crawler.crawl(psu.url, new InformatiquePowerSupplyUnitDetailParser(), arguments: psu);
        if (psu.connectors.length > 0 ) {
          psus.add(psu);
        }
      }

    }
    return psus;
  }
}


class InformatiquePowerSupplyUnitDetailParser implements PageWorker {

  parse(Document document, arguments) async {
    Product psuUnit = arguments as Product;

    psuUnit.price = price(document
        .querySelector("p.verkoopprijs")
        .text);

    var prodImgA = document.querySelector(
        "div#product-image a[data-thumbnail]");
    if (prodImgA != null) {
      psuUnit.pictureUrl = prodImgA.attributes["data-thumbnail"];
    }
    String psuConnector;
    var tables = document.querySelectorAll("table#details");
    for (var table in tables) {
      var rows = table.querySelectorAll("tr");
      for (var row in rows) {
        var label = row.querySelector("strong");
        if (label == null) {
          continue;
        } else if (label.text == "EAN code") {
          psuUnit.ean = row
              .querySelector("td:last-child")
              .text;
        } else if (label.text == "Fabrikantcode") {
          psuUnit.mpn = row
              .querySelector("tr:last-child span")
              .text;
        } else if (label.text == "Standaard") {
          psuConnector = row
              .querySelector("td:last-child")
              .text;
        }
      }
    }


    psuUnit.connectors.add(new Connector(psuConnector, "CASE"));
    String productJSON = new JsonEncoder.withIndent("  ").convert(psuUnit);
    postRequest(getBackendServerURL() + "/product/add", productJSON);
    print(productJSON);
    await sleepRnd();
  }
}