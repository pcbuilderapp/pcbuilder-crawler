import "package:pcbuilder.crawler/model/product.dart";
import "package:pcbuilder.crawler/model/connector.dart";
import "package:pcbuilder.crawler/utils.dart";
import "package:pcbuilder.crawler/crawler.dart";
import 'package:pcbuilder.crawler/pageworker.dart';

class InformatiqueVideoCardParser implements PageWorker {

  parse(Document document, arguments) async {

    var rows = document.querySelectorAll("ul.novendorlogo");

    for (Element listRow in rows) {

      var productRows = listRow.querySelectorAll("li");

      for (Element productRow in productRows){

        Product gpu = new Product();

        var querySelector = productRow.querySelector(".product_overlay");
        if (querySelector == null ){
          continue;
        }

        gpu.name = removeTip(productRow.querySelector("#title").text);
        gpu.url = querySelector.attributes["href"];
        gpu.type = "GPU";
        gpu.shop = "Informatique";

        await Crawler.crawl(gpu.url, new InformatiqueVideoCardDetailParser(), arguments: gpu);
      }
    }
  }
}

class InformatiqueVideoCardDetailParser implements PageWorker {

  parse(Document document, arguments) async {
    Product gpu = arguments as Product;

    gpu.brand = document.querySelector("span[itemprop='brand']").text;
    gpu.price = price(document.querySelector("p.verkoopprijs").text);

    var prodImgA = document.querySelector(
        "div#product-image a[data-thumbnail]");
    if (prodImgA != null) {
      gpu.pictureUrl = prodImgA.attributes["data-thumbnail"];
    }

    String gpuConnector = null;

    var tables = document.querySelectorAll("table#details");

    for (var table in tables) {

      var rows = table.querySelectorAll("tr");

      for (var row in rows) {

        var label = row.querySelector("strong");

        if (label == null) {
          continue;
        } else if (label.text == "EAN code") {
          gpu.ean = row.querySelector("td:last-child").text;
        } else if (label.text == "Fabrikantcode") {
          gpu.mpn = row.querySelector("tr:last-child span").text;
        } else if (label.text == "Bus type") {
          if(row.querySelector("td:last-child") != null){
            gpuConnector = row.querySelector("td:last-child").text.trim();
          }
        }
      }
    }

    if (gpuConnector != null){
      gpu.connectors.add(new Connector(gpuConnector, "GPU"));
    }

    await postProduct(gpu);
    await sleepRnd();
  }
}