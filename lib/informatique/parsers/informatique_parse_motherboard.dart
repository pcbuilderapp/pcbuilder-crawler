import "package:pcbuilder.crawler/model/product.dart";
import "package:pcbuilder.crawler/model/connector.dart";
import "package:pcbuilder.crawler/utils.dart";
import "package:pcbuilder.crawler/crawler.dart";
import 'dart:convert';

class InformatiqueMotherboardParser implements PageWorker {

  parse(Document document, arguments) async {

    List motherboards = [];
    var rows = document.querySelectorAll("ul.novendorlogo");
    for (Element listRow in rows) {
      var productRows = listRow.querySelectorAll("li");
      for (Element productRow in productRows){
        Product motherboard = new Product();
        var querySelector = productRow.querySelector(".product_overlay");
        if (querySelector == null ){
          continue;
        }
        motherboard.url = querySelector.attributes["href"];
        var tmpName = productRow.querySelector("#title").text;
        if (tmpName != null){
          var indexOf = tmpName.indexOf(" ");
          motherboard.brand = tmpName.substring(0, indexOf);
          motherboard.name = tmpName.substring(indexOf ,tmpName.length);
        }
        motherboard.type = "MOTHERBOARD";
        motherboard.price = price(productRow.querySelector("#price").text);
        motherboard.shop = "Informatique";
        await Crawler.crawl(motherboard.url, new InformatiqueMotherboardDetailParser(), arguments: motherboard);
        if (motherboard.connectors.length > 0 ) {
          motherboards.add(motherboard);
        }
      }

    }
    return motherboards;
  }
}


class InformatiqueMotherboardDetailParser implements PageWorker {

  parse(Document document, arguments) async {
    Product motherboard = arguments as Product;

    motherboard.price = price(document
        .querySelector("p.verkoopprijs")
        .text);

    var prodImgA = document.querySelector(
        "div#product-image a[data-thumbnail]");
    if (prodImgA != null) {
      motherboard.pictureUrl = prodImgA.attributes["data-thumbnail"];
    }
    String motherboardConnector;
    var tables = document.querySelectorAll("table#details");
    for (var table in tables) {
      var rows = table.querySelectorAll("tr");
      for (var row in rows) {
        var label = row.querySelector("strong");
        if (label == null) {
          continue;
        } else if (label.text == "EAN code") {
          motherboard.ean = row
              .querySelector("td:last-child")
              .text;
        } else if (label.text == "Fabrikantcode") {
          motherboard.mpn = row
              .querySelector("tr:last-child span")
              .text;
        } else if (label.text == "Form factor") {
          motherboardConnector = row
              .querySelector("td:last-child")
              .text;
          motherboard.connectors.add(new Connector(motherboardConnector, "CASE"));
        }else if (label.text == "Type geheugen") {
          motherboardConnector = row
              .querySelector("td:last-child")
              .text;
          motherboard.connectors.add(new Connector(motherboardConnector, "MEMORY"));
        }


      }
    }



    String productJSON = new JsonEncoder.withIndent("  ").convert(motherboard);
    postRequest(getBackendServerURL() + "/product/add", productJSON);
    print(productJSON);
    await sleepRnd();
  }
}