#!/usr/bin/env bash

# Usage:   ./collect-metadata.sh <repo-author>/<repo-name> <repo-name>
# Example: ./collect-metadata.sh Klipper3d/klipper klipper

# get pr nums and store them in txt file -> array
gh pr list --repo $1 --state merged --limit 10000 > $2-prs.txt
cut -f1 $2-prs.txt > ./pr-nums/$2-pr-nums.txt
i=0
while read line 
do
        arr[$i]="$line"
        i=$((i+1))
done < ./pr-nums/$2-pr-nums.txt

# setup csv file
echo "pr_number,pr_creator,pr_merger,code_churn,date_created,date_merged,title,body,comments,code_reviews,security_keywords" > ./metadata/$2-data.csv

# security keywords
keywords="exploit vulnerable attack unsafe vulnerability security bypass threat blacklist insecure violate expose"

# analysis
i=0
for num in "${arr[@]}"; do

  # get PR details
  gh api -X GET repos/$1/pulls/$num > ./metadata/$2-pr.json

  # pull PR information
  creator=$(cat ./metadata/$2-pr.json | jq -r '.user.login')
  merger=$(cat ./metadata/$2-pr.json | jq -r '.merged_by.login')
  additions=$(cat ./metadata/$2-pr.json | jq -r '.additions')
  deletions=$(cat ./metadata/$2-pr.json | jq -r '.deletions')
  churn=$((additions + deletions))
  cdate=$(cat ./metadata/$2-pr.json | jq -r '.created_at')
  mdate=$(cat ./metadata/$2-pr.json | jq -r '.merged_at')
  
  # store text with potential security keywords
  title=$(cat ./metadata/$2-pr.json | jq -r '.title')
  title="${title//[$'\t\r\n,']/' '}"
  body=$(cat ./metadata/$2-pr.json | jq -r '.body') 
  body="${body//[$'\t\r\n,']/' '}"
  comments=$(cat ./metadata/$2-pr.json | jq -r '.comments')
  review_comments=$(cat ./metadata/$2-pr.json | jq -r '.review_comments')
  gh api -X GET repos/$1/issues/$num/comments > ./metadata/$2-comments.json
  gh api -X GET repos/$1/pulls/$num/comments > ./metadata/$2-reviews.json
  j=0
  discussions=""
  while [ "$j" -lt "$comments" ]; do
    curr=$(cat ./metadata/$2-comments.json | jq -r ".[$j].body")
    curr="${curr//[$'\t\r\n,']/' '}"
    discussions+="$curr "
    j=$((j+1))
  done
  j=0
  reviews=""
  while [ "$j" -lt "$review_comments" ]; do
    curr=$(cat ./metadata/$2-reviews.json | jq -r ".[$j].body")
    curr="${curr//[$'\t\r\n,']/' '}"
    reviews+="$curr "
    j=$((j+1))
  done

  # analyze text for security keywords
  count=0
  for word in $keywords; do
    wc=$(grep -o "$word" <<< "$title $body $discussions $reviews" | wc -l)
    count=$(( count + wc ))
  done

  # add to csv
  echo $num,$creator,$merger,$churn,$cdate,$mdate,$title,$body,$discussions,$reviews,$count >> ./metadata/$2-data.csv

  # add to churn array for getting corresponding top 15 code churn PRs
  churn_arr[$i]="$churn"
  i=$((i+1))
done

# get total number of merged PRs
lines=$(grep "" -c ./pr-nums/$2-pr-nums.txt)
#if [[ "$lines" -lt 50 ]]; then
#  echo "skipping $3 PRs, not enough to work with"
#  exit 0
#fi
lines=$((lines-1))
nums=$(($lines / (1 + $lines*225/10000)))

# generate random numbers and store them in ./rands/<repo>-rands.txt
shuf -i 0-$lines -n $nums > rands/$2-rands.txt

# sort random numbers generated and store actual PR nums in ./rands/<repo>-prnums.txt
sort -o ./rands/$2-rands.txt ./rands/$2-rands.txt -n
while read line; do
  echo ${arr[$line]} >> ./rands/$2-prnums.txt
done < ./rands/$2-rands.txt

# get top 15 code churn PRs
for k in "${!churn_arr[@]}"; do
  echo $k ${churn_arr["$k"]}
done | sort -rn -k2 | head -n 15 > tmp.txt
prnum=$(grep -oP '^[^ ]*' tmp.txt)
for w in $prnum; do
  echo ${arr[$w]} >> ./topcc-prs/$2-ccprs.txt
done
sort -o ./topcc-prs/$2-ccprs.txt ./topcc-prs/$2-ccprs.txt -rn
rm tmp.txt

rm $2*
rm ./metadata/*.json
