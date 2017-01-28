import "package:pcbuilder.crawler/model/product.dart";
import "package:pcbuilder.crawler/model/connector.dart";
import "package:pcbuilder.crawler/utils.dart";
import "package:pcbuilder.crawler/urlcrawler.dart";
import 'package:pcbuilder.crawler/interface/pageworker.dart';
import "package:pcbuilder.crawler/model/metrics.dart";

class AlternateStorageParser implements PageWorker {
  Metrics metrics;
  AlternateStorageParser(Metrics metrics) {
    this.metrics = metrics;
  }

  parse(Document document, arguments) async {
    var rows = document.querySelectorAll("div.listRow");

    for (Element listRow in rows) {
      metrics.storageParserTime.start();

      Product storage = new Product();
      storage.name = listRow.querySelector("span.name").text.trim();
      storage.brand = listRow.querySelectorAll("span.name span")[0].text.trim();
      storage.url = "https://www.alternate.nl" +
          listRow.querySelector(".productLink").attributes["href"];
      storage.type = "STORAGE";
      storage.price = price(listRow.querySelector("span.price").text);
      setProductDiscountAlternate(listRow, storage);
      storage.shop = "Alternate";

      await UrlCrawler.crawlUrl(
          storage.url, new AlternateStorageDetailParser(metrics),
          arguments: storage);
    }
  }
}

class AlternateStorageDetailParser implements PageWorker {
  Metrics metrics;
  AlternateStorageDetailParser(Metrics metrics) {
    this.metrics = metrics;
  }

  parse(Document document, arguments) async {
    Product storage = arguments as Product;

    var dataFlix = document.querySelector("script[data-flix-mpn]");
    storage.ean = dataFlix.attributes["data-flix-ean"];
    storage.mpn = dataFlix.attributes["data-flix-mpn"];
    var picUrl =
        document.querySelector("span.picture").querySelector("img[src]");
    storage.pictureUrl = "https://www.alternate.nl" + picUrl.attributes["src"];

    var techDataTableElements =
        document.querySelectorAll("div.techData table tr");

    for (int i = 0; i < techDataTableElements.length; i++) {
      String techDataLabel =
          techDataTableElements[i].querySelector("td.c1").text.trim();
      String techData =
          techDataTableElements[i].querySelector("td.c4").text.trim();

      if (techDataLabel == "Interface") {
        storage.connectors.add(new Connector(techData, "STORAGE"));
      }
    }

    metrics.storageParserTime.stop();

    metrics.storageBackendTime.start();
    await postProduct(storage);
    metrics.storageBackendTime.stop();
    metrics.storageCount++;
  }
}
