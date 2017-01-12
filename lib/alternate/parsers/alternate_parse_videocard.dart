import "package:pcbuilder.crawler/model/product.dart";
import "package:pcbuilder.crawler/model/connector.dart";
import "package:pcbuilder.crawler/utils.dart";
import "package:pcbuilder.crawler/crawler.dart";
import 'dart:convert';

class AlternateVideoCardParser implements PageWorker {

  parse(Document document, arguments) async {

    List gpus = [];
    var rows = document.querySelectorAll("div.listRow");
    for (Element listRow in rows) {
      Product gpu = new Product();
      gpu.name = listRow.querySelector("span.name").text.trim();
      gpu.brand = listRow.querySelectorAll("span.name span")[0].text.trim();
      gpu.url = "https://www.alternate.nl" + listRow.querySelector(".productLink").attributes["href"];
      gpu.type = "GPU";
      gpu.price = price(listRow.querySelector("span.price").text);
      gpu.shop = "Alternate";
      await Crawler.crawl(gpu.url, new AlternateVideoCardDetailParser(), arguments: gpu);
      if (gpu.connectors.length > 0) {
        gpus.add(gpu);
      }
    }
    return gpus;
  }
}

class AlternateVideoCardDetailParser implements PageWorker {

  parse(Document document, arguments) async {

    Product gpu = arguments as Product;

    var dataFlix = document.querySelector("script[data-flix-mpn]");
    gpu.ean = dataFlix.attributes["data-flix-ean"];
    gpu.mpn = dataFlix.attributes["data-flix-mpn"];

    var techDataTableElements = document.querySelectorAll("div.techData table tr");
    for (int i = 0; i < techDataTableElements.length; i++) {
      String gpuConnectorData = "";
      String techDataLabel = techDataTableElements[i].querySelector("td.c1").text.trim();
      String techData = techDataTableElements[i].querySelector("td.c4").text.trim();
      var picUrl = document.querySelector("span.picture").querySelector("img[src]");
      gpu.pictureUrl = "https://www.alternate.nl" + picUrl.attributes["src"];

      if (techDataLabel == "Aansluiting") {
        for (String element in techData.split(" ")) {
          if(element.trim().substring(element.length - 1) != ")") {
            gpuConnectorData += " " + element;
          }
        }
        if (gpuConnectorData.trim() != "") {
          gpu.connectors.add(new Connector(gpuConnectorData.trim(), "GPU"));
        }
      }
    }

    if (gpu.connectors.length > 0) {
      String productJSON = new JsonEncoder.withIndent("  ").convert(gpu);
      postRequest(getBackendServerURL() + "/product/add", productJSON);
      print(productJSON);
      await sleepRnd();
    }
  }
}