import "package:pcbuilder.crawler/model/product.dart";
import "package:pcbuilder.crawler/model/connector.dart";
import "package:pcbuilder.crawler/utils.dart";
import "package:pcbuilder.crawler/crawler.dart";
import 'dart:convert';

class AlternateMotherboardParser implements PageWorker {

  parse(Document document, arguments) async {

    List motherboards = [];
    var rows = document.querySelectorAll("div.listRow");
    for (Element listRow in rows) {
      Product motherboard = new Product();
      motherboard.name = listRow.querySelector("span.name").text.trim();
      motherboard.brand = listRow.querySelectorAll("span.name span")[0].text.trim();
      motherboard.url = "https://www.alternate.nl" + listRow.querySelector(".productLink").attributes["href"];
      motherboard.type = "MOTHERBOARD";
      motherboard.price = price(listRow.querySelector("span.price").text);
      motherboard.shop = "Alternate";
      await Crawler.crawl(motherboard.url, new AlternateMotherboardDetailParser(), arguments: motherboard);

      motherboards.add(motherboard);
    }
    return motherboards;
  }
}

class AlternateMotherboardDetailParser implements PageWorker {

  parse(Document document, arguments) async {

    Product motherboard = arguments as Product;

    var dataFlix = document.querySelector("script[data-flix-mpn]");
    motherboard.ean = dataFlix.attributes["data-flix-ean"];
    motherboard.mpn = dataFlix.attributes["data-flix-mpn"];

    var techDataTableElements = document.querySelectorAll("div.techData table tr");
    for (int i = 0; i < techDataTableElements.length; i++) {
      String techDataOptional = "";
      String techDataLabel = techDataTableElements[i].querySelector("td.c1").text.trim();
      String techData = techDataTableElements[i].querySelector("td.c4").text.trim();
      if (techDataTableElements[i].querySelector("td.c2") != null) {
        techDataOptional = techDataTableElements[i].querySelector("td.c2").text.trim();
      }
      if (techDataLabel == "Socket") {
        motherboard.connectors.add(new Connector(techData, "CPU"));
      } else if (techDataLabel == "Inbouwsloten") {
        String gpuConnectorData = "";
        for (String element in techData.split(" ")) {
          if(element.substring(element.length - 1) != "x") {
            gpuConnectorData += " " + element;
          }
        }
        motherboard.connectors.add(new Connector(gpuConnectorData.trim(), "GPU"));
      } else if (techDataLabel == "FormFactor") {
        motherboard.connectors.add(new Connector(techData, "CASING"));
      } else if (techDataOptional == "Ondersteunde standaarden") {
        techData.split(",").forEach((element) => motherboard.connectors.add(new Connector(element.trim(), "MEMORY")));
      } else if (techDataOptional == "SATA") {
        motherboard.connectors.add(new Connector(techDataOptional, "STORAGE"));
      } else if (techDataOptional == "M.2") {
        motherboard.connectors.add(new Connector(techDataOptional, "STORAGE"));
      }
    }
    String productJSON = new JsonEncoder.withIndent("  ").convert(motherboard);
    postRequest(getBackendServerURL()+"/product/add", productJSON);
    print(productJSON);
    await sleepRnd();
  }
}