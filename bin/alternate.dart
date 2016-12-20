import 'package:pcbuilder.crawler/crawler.dart';
import "package:pcbuilder.crawler/model/component.dart";
import "package:pcbuilder.crawler/model/connector.dart";
import 'dart:convert';
import 'dart:io';
import 'dart:async';

List _moederborden = [];

//euro prijs naar double
double price(String price) {
  List<int> temp = [];
  for (int codeUnit in price.codeUnits) {
    if (codeUnit >= 48 && codeUnit <= 57) {
      temp.add(codeUnit);
    } else if (codeUnit == 44) {
      temp.add(46);
    } else if (codeUnit == 45) {
      temp.add(48);
    }
  }
  return double.parse(new String.fromCharCodes(temp));
}

class DetailParser implements PageWorker {
  parse(Document document, arguments) {
    Component component = arguments as Component;

    var element = document.querySelector("script[data-flix-mpn]");
    component.ean = element.attributes["data-flix-ean"];
    component.mpn = element.attributes["data-flix-mpn"];

    var techDataTableElements = document.querySelectorAll("div.techData table tr");
    for (var i = 0; i < techDataTableElements.length; i++) {
      var techDataOptional = "";
      var techDataLabel = techDataTableElements[i].querySelector("td.c1").text.trim();
      var techData = techDataTableElements[i].querySelector("td.c4").text.trim();
      if (techDataTableElements[i].querySelector("td.c2") != null) {
        techDataOptional = techDataTableElements[i].querySelector("td.c2").text.trim();
      }
      if (techDataLabel == "Socket") {
        component.connectors.add(new Connector(techData, "CPU"));
      } else if (techDataLabel == "Inbouwsloten") {
        component.connectors.add(new Connector(techData, "GPU"));
      } else if (techDataLabel == "FormFactor") {
        component.connectors.add(new Connector(techData, "CASING"));
      } else if (techDataOptional == "Ondersteunde standaarden") {
        techData.split(",").forEach((element) => component.connectors.add(new Connector(element.trim(), "MEM")));
      } else if (techDataOptional == "SATA") {
        component.connectors.add(new Connector(techDataOptional, "DISK"));
      } else if (techDataOptional == "M.2") {
        component.connectors.add(new Connector(techDataOptional, "DISK"));
      }
    }

    print(component.toJson());
  }
}

class ComponentParser implements PageWorker {
  parse(Document document,arguments) { //async {
    var rows = document.querySelectorAll("div.listRow");
    for (Element listRow in rows) {
      Component component = new Component();
      component.name = listRow.querySelector("span.name").text.trim();
      component.brand = listRow.querySelectorAll("span.name span")[0].text.trim();
      component.url = "https://www.alternate.nl" + listRow.querySelector(".productLink").attributes["href"];
      component.type = "MOTHERBOARD";
      component.price = price(listRow.querySelector("span.price").text);
      component.shopName = "Alternate";

      Crawler.crawl(component.url,new DetailParser(),arguments: component);
      //futures.add(Crawler.crawl(component.url,new DetailParser(),arguments: component));
      _moederborden.add(component);
    }

    //await Future.wait(futures);

    // meerdere pagina's?
  }
}

main(List<String> args) async {
  ComponentParser worker = new ComponentParser();

  try {
    await Crawler.crawl(
      "https://www.alternate.nl/Hardware-Componenten-Moederborden-Intel/html/listings/11626?lk=9435&size=500&showFilter=true#listingResult",
        worker,referer: "https://www.alternate.nl/Moederborden/Intel",/*cookies:cookies*/);
    String json = new JsonEncoder.withIndent("  ").convert(_moederborden);
    print("We hebben ${_moederborden.length} moederborden gevonden.");
    File uit = new File("moederborden.json");
    uit.writeAsStringSync(json);
  } catch (e) {
    print(e);
  }
}
