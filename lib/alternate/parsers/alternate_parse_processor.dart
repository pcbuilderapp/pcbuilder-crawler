import "package:pcbuilder.crawler/utils.dart";
import 'package:pcbuilder.crawler/interface/pageworker.dart';

class AlternateProcessorParser implements PageWorker {
  Metrics metrics;

  AlternateProcessorParser(Metrics metrics) {
    this.metrics = metrics;
  }

  parse(Document document, arguments) async {
    var rows = document.querySelectorAll("div.listRow");

    for (Element listRow in rows) {
      metrics.processorParserTime.start();

      Product processor = new Product();
      processor.name = listRow.querySelector("span.name").text.trim();
      processor.brand =
          listRow.querySelectorAll("span.name span")[0].text.trim();
      processor.url = "https://www.alternate.nl" +
          listRow.querySelector(".productLink").attributes["href"];
      processor.type = config["processorType"];
      processor.price = price(listRow.querySelector("span.price").text);
      setProductDiscountAlternate(listRow, processor);
      processor.shop = config["alternateName"];

      await UrlCrawler.crawlUrl(
          processor.url, new AlternateProcessorDetailParser(metrics),
          arguments: processor);
    }
  }
}

class AlternateProcessorDetailParser implements PageWorker {
  Metrics metrics;

  AlternateProcessorDetailParser(Metrics metrics) {
    this.metrics = metrics;
  }

  parse(Document document, arguments) async {
    Product processor = arguments as Product;

    var dataFlix = document.querySelector("script[data-flix-mpn]");
    processor.ean = dataFlix.attributes["data-flix-ean"];
    processor.mpn = dataFlix.attributes["data-flix-mpn"];
    var picUrl =
        document.querySelector("span.picture").querySelector("img[src]");
    processor.pictureUrl =
        "https://www.alternate.nl" + picUrl.attributes["src"];

    String cpuSocket = "";
    var techDataTableElements =
        document.querySelectorAll("div.productShort ul li");

    for (int i = 0; i < techDataTableElements.length; i++) {
      List<String> productShort = techDataTableElements[i].text.split(":");

      String techDataLabel = productShort[0];
      String techData = productShort[1];

      if (techDataLabel == "Socket") {
        if (techData != null) {
          cpuSocket = techData.trim();
        }
      }
    }

    processor.connectors.add(new Connector(cpuSocket, config["processorType"]));

    metrics.processorParserTime.stop();

    metrics.processorBackendTime.start();
    await postProduct(processor);
    metrics.processorBackendTime.stop();
    metrics.processorCount++;
  }
}
