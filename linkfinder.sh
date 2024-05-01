#!/bin/bash

domain=$1
# remove (http:// and https:// and www. and / from url)
domain_Without_Protocol=$(echo "$domain" | sed 's,http://,,;s,https://,,;s,www\.,,;s/\/$//')

mkdir -p bug_bounty_report/$domain_Without_Protocol/links
sudo chmod -R 777 bug_bounty_report


gau "$domain" --retries 10 --timeout 60 --threads 3 --providers wayback,commoncrawl,otx,urlscan --o bug_bounty_report/$domain_Without_Protocol/links/gau.txt
sudo chmod -R 777 bug_bounty_report

waymore -i "$domain" -n -mode U -oU bug_bounty_report/$domain_Without_Protocol/links/waymore.txt
sudo chmod -R 777 bug_bounty_report

waybackurls "$domain" -no-subs | tee bug_bounty_report/$domain_Without_Protocol/links/waybackurls.txt
sudo chmod -R 777 bug_bounty_report

cat bug_bounty_report/$domain_Without_Protocol/links/*.txt | sort -u | tee bug_bounty_report/$domain_Without_Protocol/links/all_links.txt
sudo chmod -R 777 bug_bounty_report