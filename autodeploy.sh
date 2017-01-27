#!/bin/bash
cd <path>
git pull
docker stop pcbuilder-crawler
docker rm pcbuilder-crawler
docker build -t pcbuilder/crawler .
docker run --name "pcbuilder-crawler" -d -t pcbuilder/crawler