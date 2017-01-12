import "package:pcbuilder.crawler/model/product.dart";
import "package:pcbuilder.crawler/model/connector.dart";
import "package:pcbuilder.crawler/utils.dart";
import "package:pcbuilder.crawler/crawler.dart";
import 'dart:convert';

class AlternateProcessorParser implements PageWorker {

  parse(Document document, arguments) async {

    List processors = [];
    var rows = document.querySelectorAll("div.listRow");
    for (Element listRow in rows) {
      Product processor = new Product();
      processor.name = listRow.querySelector("span.name").text.trim();
      processor.brand = listRow.querySelectorAll("span.name span")[0].text.trim();
      processor.url = "https://www.alternate.nl" + listRow.querySelector(".productLink").attributes["href"];
      processor.type = "CPU";
      processor.price = price(listRow.querySelector("span.price").text);
      processor.shop = "Alternate";
      await Crawler.crawl(processor.url, new AlternateProcessorDetailParser(), arguments: processor);

      processors.add(processor);
    }
    return processors;
  }
}

class AlternateProcessorDetailParser implements PageWorker {

  parse(Document document, arguments) async {

    Product processor = arguments as Product;

    var dataFlix = document.querySelector("script[data-flix-mpn]");
    processor.ean = dataFlix.attributes["data-flix-ean"];
    processor.mpn = dataFlix.attributes["data-flix-mpn"];
    var picUrl = document.querySelector("span.picture").querySelector("img[src]");
    processor.pictureUrl = "https://www.alternate.nl" + picUrl.attributes["src"];

    String cpuSocket = "";
    var techDataTableElements = document.querySelectorAll("div.productShort ul li");
    for (int i = 0; i < techDataTableElements.length; i++) {

      List<String> productShort = techDataTableElements[i].text.split(":");

      String techDataLabel = productShort[0];
      String techData = productShort[1];

      if (techDataLabel == "Socket") {
        cpuSocket = techData;
      }

    }
    processor.connectors.add(new Connector(cpuSocket, "CPU"));
    String productJSON = new JsonEncoder.withIndent("  ").convert(processor);
    postRequest(getBackendServerURL()+"/product/add", productJSON);
    print(productJSON);
    await sleepRnd();
  }
}