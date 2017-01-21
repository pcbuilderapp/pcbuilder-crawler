import "package:pcbuilder.crawler/model/product.dart";
import "package:pcbuilder.crawler/model/connector.dart";
import "package:pcbuilder.crawler/utils.dart";
import "package:pcbuilder.crawler/crawler.dart";
import 'package:pcbuilder.crawler/interface/pageworker.dart';
import "package:pcbuilder.crawler/model/metrics.dart";

class InformatiqueProcessorParser implements PageWorker {
  Metrics metrics;
  InformatiqueProcessorParser(Metrics metrics) {
    this.metrics = metrics;
  }
  parse(Document document, arguments) async {
    var rows = document.querySelectorAll("div#title");

    for (Element listRow in rows) {
      metrics.processorParserTime.start();
      Product processor = new Product();
      processor.name = removeTip(listRow.querySelector("a").text.trim());
      processor.url = listRow.querySelector("a").attributes["href"];
      processor.type = "CPU";
      processor.shop = "Informatique";

      await Crawler.crawl(
          processor.url, new InformatiqueProcessorDetailParser(metrics),
          arguments: processor);
    }
  }
}

class InformatiqueProcessorDetailParser implements PageWorker {
  Metrics metrics;
  InformatiqueProcessorDetailParser(Metrics metrics) {
    this.metrics = metrics;
  }
  parse(Document document, arguments) async {
    Product processor = arguments as Product;

    processor.brand = document.querySelector("span[itemprop='brand']").text;
    processor.price = price(document.querySelector("p.verkoopprijs").text);

    var prodImgA =
        document.querySelector("div#product-image a[data-thumbnail]");
    if (prodImgA != null) {
      processor.pictureUrl = prodImgA.attributes["data-thumbnail"];
    }

    var tables = document.querySelectorAll("table#details");

    for (var table in tables) {
      var rows = table.querySelectorAll("tr");

      for (var row in rows) {
        var label = row.querySelector("strong");
        String socket = null;

        if (label == null) {
          continue;
        } else if (label.text == "EAN code") {
          processor.ean = row.querySelector("td:last-child").text;
        } else if (label.text == "Fabrikantcode") {
          processor.mpn = row.querySelector("tr:last-child span").text;
        } else if (label.text == "Socket") {
          if (row.querySelector("td:last-child") != null) {
            socket = row.querySelector("td:last-child").text.trim();

            if (processor.brand == "Intel") {
              socket = socket.substring(1);
            }
          }

          if (socket != null) {
            processor.connectors.add(new Connector(socket, "CPU"));
          }
        }
      }
    }

    metrics.processorParserTime.stop();

    metrics.processorBackendTime.start();
    await postProduct(processor);
    metrics.processorBackendTime.stop();
    metrics.processorCount++;
  }
}
