import "package:pcbuilder.crawler/model/product.dart";
import "package:pcbuilder.crawler/model/connector.dart";
import "package:pcbuilder.crawler/utils.dart";
import "package:pcbuilder.crawler/crawler.dart";

class AlternateMotherboardParser implements PageWorker {

  parse(Document document, arguments) async {

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
    }
  }
}

class AlternateMotherboardDetailParser implements PageWorker {

  parse(Document document, arguments) async {

    Product motherboard = arguments as Product;

    var dataFlix = document.querySelector("script[data-flix-mpn]");
    motherboard.ean = dataFlix.attributes["data-flix-ean"];
    motherboard.mpn = dataFlix.attributes["data-flix-mpn"];
    var picUrl = document.querySelector("span.picture").querySelector("img[src]");
    motherboard.pictureUrl = "https://www.alternate.nl" + picUrl.attributes["src"];

    var techDataTableElements = document.querySelectorAll("div.techData table tr");

    for (int i = 0; i < techDataTableElements.length; i++) {

      String techDataOptional = "";
      String techDataLabel = "";
      if(techDataTableElements[i].querySelector("td.c1") != null){
        techDataLabel = techDataTableElements[i].querySelector("td.c1").text.trim();
      }
      String techData = "";
      if(techDataTableElements[i].querySelector("td.c4") != null){
        techData = techDataTableElements[i].querySelector("td.c4").text.trim();
      }

      if (techDataTableElements[i].querySelector("td.c2") != null) {
        techDataOptional = techDataTableElements[i].querySelector("td.c2").text.trim();
      }

      if (techDataLabel == "Socket") {
        motherboard.connectors.add(new Connector(techData, "CPU"));
      } else if (techDataLabel == "Inbouwsloten") {
        if(techData.endsWith("x16")){
          motherboard.connectors.add(new Connector(techData, "GPU"));
        }
      } else if(techData.endsWith("x1") || techData.endsWith("x2")){
        motherboard.connectors.add(new Connector(techData, "STORAGE"));
      } else if (techDataLabel == "Formfactor" || techDataLabel == "FormFactor") {
        if(techData != null){
          motherboard.connectors.add(new Connector(techData.trim(), "CASE"));
          motherboard.connectors.add(new Connector(techData.trim(), "PSU"));
        }
      } else if (techDataOptional == "Ondersteunde standaarden") {
        if(techData != null){
          motherboard.connectors.add(new Connector(techData.trim(), "MEMORY"));
        }
      } else if (techDataOptional == "SATA") {
        motherboard.connectors.add(new Connector(techDataOptional, "STORAGE"));
      } else if (techDataOptional == "M.2") {
        motherboard.connectors.add(new Connector(techDataOptional, "STORAGE"));
      } else if (techDataOptional == "mSATA") {
        motherboard.connectors.add(new Connector(techDataOptional, "STORAGE"));
      }
    }

    await postProduct(motherboard);
    await sleepRnd();
  }
}