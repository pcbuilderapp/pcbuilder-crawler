import "package:pcbuilder.crawler/utils.dart";
import 'package:pcbuilder.crawler/interface/pageworker.dart';

class AlternateVideoCardParser implements PageWorker {
  Metrics metrics;

  AlternateVideoCardParser(Metrics metrics) {
    this.metrics = metrics;
  }

  parse(Document document, arguments) async {
    var rows = document.querySelectorAll("div.listRow");

    for (Element listRow in rows) {
      metrics.videoCardParserTime.start();

      Product videoCard = new Product();
      videoCard.name = listRow.querySelector("span.name").text.trim();
      videoCard.brand =
          listRow.querySelectorAll("span.name span")[0].text.trim();
      videoCard.url = "https://www.alternate.nl" +
          listRow.querySelector(".productLink").attributes["href"];
      videoCard.type = config["graphicsCardType"];
      videoCard.price = price(listRow.querySelector("span.price").text);
      setProductDiscountAlternate(listRow, videoCard);
      videoCard.shop = config["alternateName"];

      await UrlCrawler.crawlUrl(
          videoCard.url, new AlternateVideoCardDetailParser(metrics),
          arguments: videoCard);
    }
  }
}

class AlternateVideoCardDetailParser implements PageWorker {
  Metrics metrics;

  AlternateVideoCardDetailParser(Metrics metrics) {
    this.metrics = metrics;
  }

  parse(Document document, arguments) async {
    Product videoCard = arguments as Product;

    var dataFlix = document.querySelector("script[data-flix-mpn]");
    videoCard.ean = dataFlix.attributes["data-flix-ean"];
    videoCard.mpn = dataFlix.attributes["data-flix-mpn"];

    var techDataTableElements =
        document.querySelectorAll("div.techData table tr");

    for (int i = 0; i < techDataTableElements.length; i++) {
      String techDataLabel =
          techDataTableElements[i].querySelector("td.c1").text.trim();
      String techData =
          techDataTableElements[i].querySelector("td.c4").text.trim();
      var picUrl =
          document.querySelector("span.picture").querySelector("img[src]");
      videoCard.pictureUrl =
          "https://www.alternate.nl" + picUrl.attributes["src"];

      if (techDataLabel == "Aansluiting") {
        if (techData != "") {
          videoCard.connectors.add(new Connector(techData, config["graphicsCardType"]));
        }
      }
    }

    metrics.videoCardParserTime.stop();

    metrics.videoCardBackendTime.start();
    await postProduct(videoCard);
    metrics.videoCardBackendTime.stop();
    metrics.videoCardCount++;
  }
}
