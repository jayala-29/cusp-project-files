#!/usr/bin/env bash

while read line 
do
  cp $line ErrorQueries 
done < q.txt
