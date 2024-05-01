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

echo " "
echo "######################################################"
echo "################## All Links Collected ###############"
echo "######################################################"
echo " "
sudo chmod -R 777 bug_bounty_report

cat bug_bounty_report/$domain_Without_Protocol/links/all_links.txt | sort -u | grep -E '.js$' > bug_bounty_report/$domain_Without_Protocol/links/js_links.txt
sudo chmod -R 777 bug_bounty_report
echo " "
echo "######################################################"
echo "################## JS Links Collected ################"
echo "######################################################"
echo " "

cat bug_bounty_report/$domain_Without_Protocol/links/js_links.txt | while read url; do secretfinder -i $url -o cli | tee -a bug_bounty_report/$domain_Without_Protocol/links/js_secrets.txt; done
sudo chmod -R 777 bug_bounty_report
echo " "
echo "######################################################"
echo "####### JS secrets and Endpoints Collected ###########"
echo "######################################################"
echo " "