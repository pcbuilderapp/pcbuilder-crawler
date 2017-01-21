import "package:pcbuilder.crawler/model/product.dart";
import "package:pcbuilder.crawler/model/connector.dart";
import "package:pcbuilder.crawler/utils.dart";
import "package:pcbuilder.crawler/crawler.dart";
import 'package:pcbuilder.crawler/interface/pageworker.dart';

class InformatiqueMemoryParser implements PageWorker {

  parse(Document document, arguments) async {

    var rows = document.querySelectorAll("ul.novendorlogo");

    for (Element listRow in rows) {

      var productRows = listRow.querySelectorAll("li");

      for (Element productRow in productRows){

        Product memory = new Product();
        var querySelector = productRow.querySelector(".product_overlay");

        if (querySelector == null ){
          continue;
        }

        memory.name = removeTip(productRow.querySelector("#title").text);
        memory.url = querySelector.attributes["href"];
        memory.type = "MEMORY";
        memory.shop = "Informatique";

        Element memoryConnector = document.querySelector("#hdr");

        if (memoryConnector != null){
          String memoryString = memoryConnector.text;
          memoryString = memoryString.replaceAll(" modules", "");
          memory.connectors.add(new Connector(memoryString, "MEMORY"));
        }

        await Crawler.crawl(memory.url, new InformatiqueMemoryDetailParser(), arguments: memory);
      }
    }
  }
}

class InformatiqueMemoryDetailParser implements PageWorker {

  parse(Document document, arguments) async {

    Product memory = arguments as Product;

    memory.brand = document.querySelector("span[itemprop='brand']").text;
    memory.price = price(document.querySelector("p.verkoopprijs").text);

    var prodImgA = document.querySelector("div#product-image a[data-thumbnail]");
    if (prodImgA != null) {
      memory.pictureUrl = prodImgA.attributes["data-thumbnail"];
    }

    var tables = document.querySelectorAll("table#details");

    for (var table in tables) {

      var rows = table.querySelectorAll("tr");

      for (var row in rows) {

        var label = row.querySelector("strong");

        if (label == null) {

          continue;

        } else if (label.text == "EAN code") {

          memory.ean = row.querySelector("td:last-child").text;

        } else if (label.text == "Fabrikantcode") {

          memory.mpn = row.querySelector("tr:last-child span").text;

        }
      }
    }

    await postProduct(memory);
  }
}