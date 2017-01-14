import "package:pcbuilder.crawler/model/product.dart";
import "package:pcbuilder.crawler/model/connector.dart";
import "package:pcbuilder.crawler/utils.dart";
import "package:pcbuilder.crawler/crawler.dart";

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

        gpu.url = querySelector.attributes["href"];
        var tmpName = productRow.querySelector("#title").text;

        if (tmpName != null){
          var indexOf = tmpName.indexOf(" ");
          gpu.brand = tmpName.substring(0, indexOf);
          gpu.name = tmpName.substring(indexOf ,tmpName.length);
        }

        gpu.type = "GPU";
        gpu.price = price(productRow.querySelector("#price").text);
        gpu.shop = "Informatique";

        await Crawler.crawl(gpu.url, new InformatiqueVideoCardDetailParser(), arguments: gpu);
      }
    }
  }
}

class InformatiqueVideoCardDetailParser implements PageWorker {

  parse(Document document, arguments) async {
    Product gpuUnit = arguments as Product;

    gpuUnit.price = price(document
        .querySelector("p.verkoopprijs")
        .text);

    var prodImgA = document.querySelector(
        "div#product-image a[data-thumbnail]");
    if (prodImgA != null) {
      gpuUnit.pictureUrl = prodImgA.attributes["data-thumbnail"];
    }

    String gpuConnector;

    var tables = document.querySelectorAll("table#details");

    for (var table in tables) {

      var rows = table.querySelectorAll("tr");

      for (var row in rows) {

        var label = row.querySelector("strong");

        if (label == null) {
          continue;
        } else if (label.text == "EAN code") {
          gpuUnit.ean = row
              .querySelector("td:last-child")
              .text;
        } else if (label.text == "Fabrikantcode") {
          gpuUnit.mpn = row
              .querySelector("tr:last-child span")
              .text;
        } else if (label.text == "Geheugentype") {
          gpuConnector = row
              .querySelector("td:last-child")
              .text;
        }
      }
    }

    gpuUnit.connectors.add(new Connector(gpuConnector, "GPU"));

    await postProduct(gpuUnit);
    await sleepRnd();
  }
}