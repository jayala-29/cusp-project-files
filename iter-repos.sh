#!/usr/bin/env bash

while IFS= read -r line
do
  sub=$(echo $line | cut -d "/" -f2)
  ./collect-metadata.sh $line $sub
  ./run-codeql.sh https://github.com/$line.git $line $sub
done < repos.txt
