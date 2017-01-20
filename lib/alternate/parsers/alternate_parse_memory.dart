import "package:pcbuilder.crawler/model/product.dart";
import "package:pcbuilder.crawler/model/connector.dart";
import "package:pcbuilder.crawler/utils.dart";
import "package:pcbuilder.crawler/crawler.dart";
import 'package:pcbuilder.crawler/pageworker.dart';

class AlternateMemoryParser implements PageWorker {

  parse(Document document, arguments) async {

    var rows = document.querySelectorAll("div.listRow");

    for (Element listRow in rows) {

      Product memory = new Product();
      memory.name = listRow.querySelector("span.name").text.trim();
      memory.brand = listRow.querySelectorAll("span.name span")[0].text.trim();
      memory.url = "https://www.alternate.nl" + listRow.querySelector(".productLink").attributes["href"];
      memory.type = "MEMORY";
      memory.price = price(listRow.querySelector("span.price").text);
      memory.shop = "Alternate";

      await Crawler.crawl(memory.url, new AlternateMemoryDetailParser(), arguments: memory);
    }
  }
}

class AlternateMemoryDetailParser implements PageWorker {

  parse(Document document, arguments) async {

    Product memory = arguments as Product;

    var dataFlix = document.querySelector("script[data-flix-mpn]");
    memory.ean = dataFlix.attributes["data-flix-ean"];
    memory.mpn = dataFlix.attributes["data-flix-mpn"];
    var picUrl = document.querySelector("span.picture").querySelector("img[src]");
    memory.pictureUrl = "https://www.alternate.nl" + picUrl.attributes["src"];

    String memType = "";

    var techDataTableElements = document.querySelectorAll("div.techData table tr");

    for (int i = 0; i < techDataTableElements.length; i++) {

      String techDataLabel = techDataTableElements[i].querySelector("td.c1").text.trim();
      String techData = techDataTableElements[i].querySelector("td.c4").text.trim();

      if (techDataLabel == "Standaard") {
        memType = techData.split(" ")[0];
      }
    }

    memory.connectors.add(new Connector(memType, "MEMORY"));

    await postProduct(memory);
    await sleepRnd();

  }
}