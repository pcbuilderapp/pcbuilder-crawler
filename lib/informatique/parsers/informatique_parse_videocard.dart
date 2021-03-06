import "package:pcbuilder.crawler/utils.dart";
import 'package:pcbuilder.crawler/interface/pageworker.dart';

class InformatiqueVideoCardParser implements PageWorker {
  Metrics metrics;

  InformatiqueVideoCardParser(Metrics metrics) {
    this.metrics = metrics;
  }

  parse(Document document, arguments) async {
    var rows = document.querySelectorAll("div#title");

    for (Element listRow in rows) {
      metrics.videoCardParserTime.start();

      Product videoCard = new Product();

      videoCard.name = removeTip(listRow.querySelector("a").text.trim());
      videoCard.url = listRow.querySelector("a").attributes["href"];
      videoCard.type = config["graphicsCardType"];
      videoCard.shop = config["informatiqueName"];

      await UrlCrawler.crawlUrl(
          videoCard.url, new InformatiqueVideoCardDetailParser(metrics),
          arguments: videoCard);
    }
  }
}

class InformatiqueVideoCardDetailParser implements PageWorker {
  Metrics metrics;
  InformatiqueVideoCardDetailParser(Metrics metrics) {
    this.metrics = metrics;
  }
  parse(Document document, arguments) async {
    Product videoCard = arguments as Product;

    videoCard.brand = document.querySelector("span[itemprop='brand']").text;
    videoCard.price = price(document.querySelector("p.verkoopprijs").text);
    setProductDiscountInformatique(document, videoCard);

    var prodImgA =
        document.querySelector("div#product-image a[data-thumbnail]");
    if (prodImgA != null) {
      videoCard.pictureUrl = prodImgA.attributes["data-thumbnail"];
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
          videoCard.ean = row.querySelector("td:last-child").text;
        } else if (label.text == "Fabrikantcode") {
          videoCard.mpn = row.querySelector("tr:last-child span").text;
        } else if (label.text == "Bus type") {
          if (row.querySelector("td:last-child") != null) {
            gpuConnector = row.querySelector("td:last-child").text.trim();
          }
        }
      }
    }

    if (gpuConnector != null) {
      videoCard.connectors.add(new Connector(gpuConnector, config["graphicsCardType"]));
    }

    metrics.videoCardParserTime.stop();

    metrics.videoCardBackendTime.start();
    await postProduct(videoCard);
    metrics.videoCardBackendTime.stop();
    metrics.videoCardCount++;
  }
}
