FROM debian:jessie-slim

RUN apt-get update && apt-get dist-upgrade
RUN apt-get install apt-transport-https curl
RUN sh -c 'curl https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -'
RUN sh -c 'curl https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'
RUN apt-get update && apt-get install dart
RUN ln -s /usr/lib/dart/bin/pub /usr/bin/pub

WORKDIR /pcbuilder

ADD pubspec.* /pcbuilder/
RUN pub get
ADD . /pcbuilder
RUN pub get --offline

CMD []
ENTRYPOINT ["/usr/bin/dart", "bin/pcbuildercrawler.dart"]
