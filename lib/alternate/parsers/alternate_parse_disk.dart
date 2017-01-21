import "package:pcbuilder.crawler/model/product.dart";
import "package:pcbuilder.crawler/model/connector.dart";
import "package:pcbuilder.crawler/utils.dart";
import "package:pcbuilder.crawler/crawler.dart";
import 'package:pcbuilder.crawler/interface/pageworker.dart';
import "package:pcbuilder.crawler/model/metrics.dart";

class AlternateDiskParser implements PageWorker {

  Metrics metrics;
  AlternateDiskParser(Metrics metrics) {
    this.metrics = metrics;
  }

  parse(Document document, arguments) async {

    metrics.storageParserTime.start();

    var rows = document.querySelectorAll("div.listRow");

    for (Element listRow in rows) {

      Product disk = new Product();
      disk.name = listRow.querySelector("span.name").text.trim();
      disk.brand = listRow.querySelectorAll("span.name span")[0].text.trim();
      disk.url = "https://www.alternate.nl" + listRow.querySelector(".productLink").attributes["href"];
      disk.type = "STORAGE";
      disk.price = price(listRow.querySelector("span.price").text);
      disk.shop = "Alternate";

      await Crawler.crawl(disk.url, new AlternateDiskDetailParser(metrics), arguments: disk);
    }
  }
}

class AlternateDiskDetailParser implements PageWorker {

  Metrics metrics;
  AlternateDiskDetailParser(Metrics metrics) {
    this.metrics = metrics;
  }

  parse(Document document, arguments) async {

    Product disk = arguments as Product;

    var dataFlix = document.querySelector("script[data-flix-mpn]");
    disk.ean = dataFlix.attributes["data-flix-ean"];
    disk.mpn = dataFlix.attributes["data-flix-mpn"];
    var picUrl = document.querySelector("span.picture").querySelector("img[src]");
    disk.pictureUrl = "https://www.alternate.nl" + picUrl.attributes["src"];

    var techDataTableElements = document.querySelectorAll("div.techData table tr");

    for (int i = 0; i < techDataTableElements.length; i++) {

      String techDataLabel = techDataTableElements[i].querySelector("td.c1").text.trim();
      String techData = techDataTableElements[i].querySelector("td.c4").text.trim();

      if (techDataLabel == "Interface") {
        disk.connectors.add(new Connector(techData, "STORAGE"));
      }
    }

    metrics.storageParserTime.stop();

    metrics.storageBackendTime.start();
    await postProduct(disk);
    metrics.storageBackendTime.stop();

  }
}