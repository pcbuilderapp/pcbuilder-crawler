import "package:pcbuilder.crawler/model/product.dart";
import "package:pcbuilder.crawler/model/connector.dart";
import "package:pcbuilder.crawler/utils.dart";
import "package:pcbuilder.crawler/crawler.dart";

class InformatiqueDiskParser implements PageWorker {
  parse(Document document, arguments) async {
    var rows = document.querySelectorAll("ul.novendorlogo");

    for (Element listRow in rows) {
      var productRows = listRow.querySelectorAll("li");

      for (Element productRow in productRows) {
        Product disk = new Product();

        var querySelector = productRow.querySelector(".product_overlay");
        if (querySelector == null) {
          continue;
        }

        disk.name = removeTip(productRow.querySelector("#title").text);
        disk.url = querySelector.attributes["href"];
        disk.type = "STORAGE";
        disk.shop = "Informatique";

        await Crawler.crawl(disk.url, new InformatiqueDiskDetailParser(),
            arguments: disk);
      }
    }
  }
}

class InformatiqueDiskDetailParser implements PageWorker {
  parse(Document document, arguments) async {
    Product disk = arguments as Product;

    disk.brand = document.querySelector("span[itemprop='brand']").text;
    disk.price = price(document.querySelector("p.verkoopprijs").text);

    var prodImgA =
        document.querySelector("div#product-image a[data-thumbnail]");
    if (prodImgA != null) {
      disk.pictureUrl = prodImgA.attributes["data-thumbnail"];
    }

    var tables = document.querySelectorAll("table#details");

    for (var table in tables) {
      var rows = table.querySelectorAll("tr");

      for (var row in rows) {
        var label = row.querySelector("strong");

        if (label == null) {
          continue;
        } else if (label.text == "EAN code") {
          disk.ean = row.querySelector("td:last-child").text;
        } else if (label.text == "Fabrikantcode") {
          disk.mpn = row.querySelector("tr:last-child span").text;
        }

        if(disk.ean != null && disk.mpn != null){
          break;
        }
      }
    }

    var querySelector =
        document.querySelector("#description").querySelector("span");
    var innerHtml = querySelector.innerHtml;
    disk.connectors.add(new Connector(innerHtml, "STORAGE"));

    await postProduct(disk);
    await sleepRnd();
  }
}
