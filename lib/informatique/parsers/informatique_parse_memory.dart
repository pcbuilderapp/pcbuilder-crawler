import "package:pcbuilder.crawler/utils.dart";
import 'package:pcbuilder.crawler/interface/pageworker.dart';

class InformatiqueMemoryParser implements PageWorker {
  Metrics metrics;
  InformatiqueMemoryParser(Metrics metrics) {
    this.metrics = metrics;
  }

  parse(Document document, arguments) async {
    var rows = document.querySelectorAll("div#title");

    for (Element listRow in rows) {
      metrics.memoryParserTime.start();

      Product memory = new Product();

      memory.name = removeTip(listRow.querySelector("a").text.trim());
      memory.url = listRow.querySelector("a").attributes["href"];
      memory.type = config["memoryType"];
      memory.shop = config["informatiqueName"];

      Element memoryConnector = document.querySelector("#hdr");

      if (memoryConnector != null) {
        String memoryString = memoryConnector.text;
        memoryString = memoryString.replaceAll(" modules", "");
        memory.connectors.add(new Connector(memoryString, config["memoryType"]));
      }

      await UrlCrawler.crawlUrl(
          memory.url, new InformatiqueMemoryDetailParser(metrics),
          arguments: memory);
      }
  }
}

class InformatiqueMemoryDetailParser implements PageWorker {
  Metrics metrics;
  InformatiqueMemoryDetailParser(Metrics metrics) {
    this.metrics = metrics;
  }
  parse(Document document, arguments) async {
    Product memory = arguments as Product;

    memory.brand = document.querySelector("span[itemprop='brand']").text;
    memory.price = price(document.querySelector("p.verkoopprijs").text);
    setProductDiscountInformatique(document, memory);

    var prodImgA =
        document.querySelector("div#product-image a[data-thumbnail]");
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

    metrics.memoryParserTime.stop();

    metrics.memoryBackendTime.start();
    await postProduct(memory);
    metrics.memoryBackendTime.stop();
    metrics.memoryCount++;
  }
}
