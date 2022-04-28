#!/usr/bin/env bash

# Usage:   ./run-codeql.sh <clone-link> <repo-author>/<repo-name> <repo-name>
# Example: ./run-codeql.sh https://github.com/Klipper3d/klipper.git Klipper3d/klipper klipper

# clone repo into repos directory
cd repos
git clone $1
cd ..
mkdir rand-results/$3
mkdir cc-results/$3

# random PRs CodeQL analysis
while read line; do

  # store current PR
  curr=$line

  # get PR details and git checkout
  cd ./repos/$3
  var=$(gh pr checkout $curr --detach 2>&1)
  if grep -q "fatal: couldn't find remote ref" <<< "$var"; then
    gh api -X GET repos/$2/pulls/$curr > $3-pr.json
    sha=$(cat $3-pr.json | jq -r '.merge_commit_sha')
    git checkout $sha
  fi
  
  # CodeQL analysis
  cd ../..
  $PWD/codeql-cli/codeql database create ./databases/$3 --source-root="./repos/$3" --language="python" --overwrite -j 6
  $PWD/codeql-cli/codeql database analyze --format="csv" --output="./rand-results/$3/$curr.csv" ./databases/$3 $PWD/queries/python/ql/src/ErrorQueries -j 6
  echo -e "name,description,severity,message,path,start_line,start_column,end_line,end_column\n$(cat rand-results/$3/$curr.csv)" > ./rand-results/$3/$curr.csv

  # get state before current PR details and git checkout
  cd ./repos/$3
  sha=$(git log -n 2 | grep -E 'commit [a-z0-9]{30}') 
  sha=${sha//commit /} 
  sha=${sha:41}
  git checkout $sha
  
  # CodeQL analysis
  cd ../..
  $PWD/codeql-cli/codeql database create ./databases/$3 --source-root="./repos/$3" --language="python" --overwrite -j 6
  $PWD/codeql-cli/codeql database analyze --format="csv" --output="./rand-results/$3/$curr-before.csv" ./databases/$3 $PWD/queries/python/ql/src/ErrorQueries -j 6
  echo -e "name,description,severity,message,path,start_line,start_column,end_line,end_column\n$(cat rand-results/$3/$curr-before.csv)" > ./rand-results/$3/$curr-before.csv

done < ./rands/$3-prnums.txt

# top 15 code churn PRs CodeQL analysis
while read line; do

  # store current PR
  curr=$line

  # get PR details and git checkout
  cd ./repos/$3
  var=$(gh pr checkout $curr --detach 2>&1)
  if grep -q "fatal: couldn't find remote ref" <<< "$var"; then
    gh api -X GET repos/$2/pulls/$curr > $3-pr.json
    sha=$(cat $3-pr.json | jq -r '.merge_commit_sha')
    git checkout $sha
  fi
  
  # CodeQL analysis
  cd ../..
  $PWD/codeql-cli/codeql database create ./databases/$3 --source-root="./repos/$3" --language="python" --overwrite -j 5
  $PWD/codeql-cli/codeql database analyze --format="csv" --output="./cc-results/$3/$curr.csv" ./databases/$3 $PWD/queries/python/ql/src/ErrorQueries -j 5
  echo -e "name,description,severity,message,path,start_line,start_column,end_line,end_column\n$(cat cc-results/$3/$curr.csv)" > ./cc-results/$3/$curr.csv

  # get state before current PR details and git checkout
  cd ./repos/$3
  sha=$(git log -n 2 | grep -E 'commit [a-z0-9]{30}') 
  sha=${sha//commit /} 
  sha=${sha:41}
  git checkout $sha
  
  # CodeQL analysis
  cd ../..
  $PWD/codeql-cli/codeql database create ./databases/$3 --source-root="./repos/$3" --language="python" --overwrite -j 5
  $PWD/codeql-cli/codeql database analyze --format="csv" --output="./cc-results/$3/$curr-before.csv" ./databases/$3 $PWD/queries/python/ql/src/ErrorQueries  -j 5
  echo -e "name,description,severity,message,path,start_line,start_column,end_line,end_column\n$(cat cc-results/$3/$curr-before.csv)" > ./cc-results/$3/$curr-before.csv

done < ./topcc-prs/$3-ccprs.txt
