import 'package:pcbuilder.crawler/crawler.dart';
import "package:pcbuilder.crawler/model/component.dart";
import "package:pcbuilder.crawler/model/connector.dart";
import 'dart:convert';
import 'dart:io';
import 'dart:async';

List _moederborden = [];

//euro prijs naar double
double prijsje(String prijs) {
  List<int> temp = [];
  for (int codeUnit in prijs.codeUnits) {
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
  parse(Document document,arguments) {
    Component component = arguments as Component;
    var element = document.querySelector("script[data-flix-mpn]");
    component.ean = element.attributes["data-flix-ean"];
    component.mpn = element.attributes["data-flix-mpn"];
    print(component.toJson());
  }
}

class MotherboardParser implements PageWorker {
  parse(Document document,arguments) async {
    var rows = document.querySelectorAll("div.listRow");
    var futures = [];
    for (Element listRow in rows) {
      Component bord = new Component();
      bord.name = listRow.querySelector("span.name").text.trim();
      bord.brand = listRow.querySelectorAll("span.name span")[0].text.trim();
      bord.url = "https://www.alternate.nl" + listRow.querySelector(".productLink").attributes["href"];

      futures.add(Crawler.crawl(bord.url,new DetailParser(),arguments: bord));

      bord.type = "MOTHERBOARD";
      var fields = listRow.querySelectorAll("span.info");
      bord.connectors.add(new Connector(fields[0].text.trim(), "CASING"));
      bord.price = prijsje(listRow.querySelector("span.price").text);
      bord.shopName = "Alternate";
      print(bord.toJson());
      _moederborden.add(bord);
    }

    await Future.wait(futures);

    // meerdere pagina's?
  }
}

main(List<String> args) async {
  MotherboardParser worker = new MotherboardParser();

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
