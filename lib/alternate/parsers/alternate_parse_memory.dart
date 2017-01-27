import "package:pcbuilder.crawler/model/product.dart";
import "package:pcbuilder.crawler/model/connector.dart";
import "package:pcbuilder.crawler/utils.dart";
import "package:pcbuilder.crawler/urlcrawler.dart";
import 'package:pcbuilder.crawler/interface/pageworker.dart';
import "package:pcbuilder.crawler/model/metrics.dart";

class AlternateMemoryParser implements PageWorker {
  Metrics metrics;
  AlternateMemoryParser(Metrics metrics) {
    this.metrics = metrics;
  }

  parse(Document document, arguments) async {
    var rows = document.querySelectorAll("div.listRow");

    for (Element listRow in rows) {
      metrics.memoryParserTime.start();

      Product memory = new Product();
      memory.name = listRow.querySelector("span.name").text.trim();
      memory.brand = listRow.querySelectorAll("span.name span")[0].text.trim();
      memory.url = "https://www.alternate.nl" +
          listRow.querySelector(".productLink").attributes["href"];
      memory.type = "MEMORY";
      memory.price = price(listRow.querySelector("span.price").text);
      memory.shop = "Alternate";

      await UrlCrawler.crawlUrl(memory.url, new AlternateMemoryDetailParser(metrics),
          arguments: memory);
    }
  }
}

class AlternateMemoryDetailParser implements PageWorker {
  Metrics metrics;
  AlternateMemoryDetailParser(Metrics metrics) {
    this.metrics = metrics;
  }

  parse(Document document, arguments) async {
    Product memory = arguments as Product;

    var dataFlix = document.querySelector("script[data-flix-mpn]");
    memory.ean = dataFlix.attributes["data-flix-ean"];
    memory.mpn = dataFlix.attributes["data-flix-mpn"];
    var picUrl =
        document.querySelector("span.picture").querySelector("img[src]");
    memory.pictureUrl = "https://www.alternate.nl" + picUrl.attributes["src"];

    String memType = "";

    var techDataTableElements =
        document.querySelectorAll("div.techData table tr");

    for (int i = 0; i < techDataTableElements.length; i++) {
      String techDataLabel =
          techDataTableElements[i].querySelector("td.c1").text.trim();
      String techData =
          techDataTableElements[i].querySelector("td.c4").text.trim();

      if (techDataLabel == "Standaard") {
        memType = techData.split(" ")[0];
      }
    }

    memory.connectors.add(new Connector(memType, "MEMORY"));

    metrics.memoryParserTime.stop();

    metrics.memoryBackendTime.start();
    await postProduct(memory);
    metrics.memoryBackendTime.stop();
    metrics.memoryCount++;
  }
}
