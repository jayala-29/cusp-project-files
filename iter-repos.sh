#!/usr/bin/env bash

while IFS= read -r line
do
  sub=$(echo $line | cut -d "/" -f2)
  cm=$(./collect-metadata.sh $line $sub)
  if grep -q "skipping" <<< "$cm"; then
    echo $cm
    continue
  fi
  ./run-codeql.sh https://github.com/$line.git $line $sub
done < repos.txt
