import "package:pcbuilder.crawler/model/product.dart";
import "package:pcbuilder.crawler/model/connector.dart";
import "package:pcbuilder.crawler/utils.dart";
import "package:pcbuilder.crawler/crawler.dart";
import 'dart:convert';

class InformatiqueMemoryParser implements PageWorker {

  parse(Document document, arguments) async {

    List memoryUnits = [];
    var rows = document.querySelectorAll("ul.novendorlogo");
    for (Element listRow in rows) {
      var productRows = listRow.querySelectorAll("li");
      for (Element productRow in productRows){
        Product memory = new Product();
        var querySelector = productRow.querySelector(".product_overlay");
        if (querySelector == null ){
          continue;
        }
        memory.url = querySelector.attributes["href"];
        var tmpName = productRow.querySelector("#title").text;
        if (tmpName != null){
          var indexOf = tmpName.indexOf(" ");
          memory.brand = tmpName.substring(0, indexOf);
          memory.name = tmpName.substring(indexOf ,tmpName.length);
          if (memory.name.contains("(tip)")){
            memory.name = memory.name.replaceAll("(tip)", "");
          }
        }
        memory.type = "MEM";
        Element priceSelector = productRow.querySelector("#price");
        if (priceSelector != null){
          memory.price = price(priceSelector.text);
        }
        memory.shop = "Informatique";
        Element memoryConnector = document.querySelector("#hdr");
        if (memoryConnector != null){
          String memoryString = memoryConnector.text;
          memoryString = memoryString.replaceAll(" modules", "");
          memory.connectors.add(new Connector(memoryString, "MEMORY"));
        }

        await Crawler.crawl(memory.url, new InformatiqueMemoryDetailParser(), arguments: memory);
        if (memory.connectors.length > 0 ) {
          memoryUnits.add(memory);
        }
      }

    }
    return memoryUnits;
  }
}

class InformatiqueMemoryDetailParser implements PageWorker {

  parse(Document document, arguments) async {

    Product memory = arguments as Product;

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

    String productJSON = new JsonEncoder.withIndent("  ").convert(memory);
    postRequest(getBackendServerURL()+"/product/add", productJSON);
    print(productJSON);
    await sleepRnd();


  }
}