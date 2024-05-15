#!/usr/bin/env bash

# Function to display usage message
display_usage() {
    echo "Usage:"
    echo "     $0 -s http://example.com"
    echo ""
    echo "Options:"
    echo "  -h               Display this help message"
    echo "  -s               Single Domain Parameter Spidering"
    echo "  -m               Multi Domain Parameter Spidering"
    echo ""
    echo "Required Tools:"
    echo "              https://github.com/tomnomnom/unfurl
              https://github.com/xnl-h4ck3r/waymore
              https://github.com/m4ll0k/SecretFinder"
    exit 0
}

if [[ "$1" == "-h" ]]; then
    display_usage
    exit 0
fi

if [[ "$1" == "-s" ]]; then
    domain_Without_Protocol=$(echo "$2" | unfurl -u domains)
    mkdir -p bug_bounty_report/$domain_Without_Protocol/recon/links

    echo "===================================================="
    echo "========= Single Domain URLs collecting ============"
    echo "===================================================="
    echo ""
    waymore -i "$domain_Without_Protocol" -c ~/config.yml -f -mc 200 -n -mode U -oU bug_bounty_report/$domain_Without_Protocol/recon/links/waymore.txt
    echo ""
    echo "===================================================="
    echo "=== Single Domain URLs collecting finished ========="
    echo "===================================================="

    cat bug_bounty_report/$domain_Without_Protocol/recon/links/waymore.txt | sort -u | tee bug_bounty_report/$domain_Without_Protocol/recon/links/all_urls.txt

    echo "===================================================="
    echo "======= Single Domain Parameter collecting ========="
    echo "===================================================="
    echo ""
    cat bug_bounty_report/$domain_Without_Protocol/recon/links/all_urls.txt | sort -u | grep "=" | egrep -iv ".(jpg|jpeg|gif|css|tif|tiff|png|ttf|woff|woff2|ico|pdf|svg|txt|js)" | tee bug_bounty_report/$domain_Without_Protocol/recon/links/all_parameters.txt

    cat bug_bounty_report/$domain_Without_Protocol/recon/links/all_parameters.txt | wc -l
    echo ""
    echo "===================================================="
    echo "============= Single Domain Parameters ============="
    echo "===================================================="


    echo ""
    echo "######################################################"
    echo "################## JS Links Collecting ###############"
    echo "######################################################"
    echo ""
    cat bug_bounty_report/$domain_Without_Protocol/recon/links/all_urls.txt | sort -u | grep -E "\.js$" > bug_bounty_report/$domain_Without_Protocol/recon/links/js_links.txt
    echo ""
    echo "######################################################"
    echo "########### JS Links Collecting finished #############"
    echo "######################################################"
    echo ""


    echo ""
    echo "######################################################"
    echo "####### JS secrets and Endpoints Collecting ###########"
    echo "######################################################"
    echo ""
    cat bug_bounty_report/$domain_Without_Protocol/recon/links/js_links.txt | while read url; do secretfinder -i "$url" -o cli | tee -a bug_bounty_report/$domain_Without_Protocol/recon/links/js_secrets.txt; done

    echo ""
    echo "######################################################"
    echo "####### JS secrets and Endpoints Collected ###########"
    echo "######################################################"
    echo ""
    exit 0

fi

if [[ "$1" == "-m" ]]; then
    domain_Without_Protocol=$(echo "$2" | unfurl -u domains)
    mkdir -p bug_bounty_report/$domain_Without_Protocol/recon/links

    echo "===================================================="
    echo "========= Single Domain URLs collecting ============"
    echo "===================================================="
    echo ""
    waymore -i "$domain_Without_Protocol" -c ~/config.yml -f -mc 200 -mode U -oU bug_bounty_report/$domain_Without_Protocol/recon/links/waymore-wide.txt
    echo ""
    echo "===================================================="
    echo "=== Single Domain URLs collecting finished ========="
    echo "===================================================="

    cat bug_bounty_report/$domain_Without_Protocol/recon/links/waymore-wide.txt | sort -u | tee bug_bounty_report/$domain_Without_Protocol/recon/links/all_urls-wide.txt

    echo "===================================================="
    echo "======= Single Domain Parameter collecting ========="
    echo "===================================================="
    echo ""
    cat bug_bounty_report/$domain_Without_Protocol/recon/links/all_urls-wide.txt | sort -u | grep "=" | egrep -iv ".(jpg|jpeg|gif|css|tif|tiff|png|ttf|woff|woff2|ico|pdf|svg|txt|js)" | tee bug_bounty_report/$domain_Without_Protocol/recon/links/all_parameters-wide.txt

    cat bug_bounty_report/$domain_Without_Protocol/recon/links/all_parameters-wide.txt | wc -l
    echo ""
    echo "===================================================="
    echo "============= Single Domain Parameters ============="
    echo "===================================================="


    echo ""
    echo "######################################################"
    echo "################## JS Links Collecting ###############"
    echo "######################################################"
    echo ""
    cat bug_bounty_report/$domain_Without_Protocol/recon/links/all_urls-wide.txt | sort -u | grep -E "\.js$" > bug_bounty_report/$domain_Without_Protocol/recon/links/js_links-wide.txt
    echo ""
    echo "######################################################"
    echo "########### JS Links Collecting finished #############"
    echo "######################################################"
    echo ""


    echo ""
    echo "######################################################"
    echo "####### JS secrets and Endpoints Collecting ##########"
    echo "######################################################"
    echo ""
    cat bug_bounty_report/$domain_Without_Protocol/recon/links/js_links-wide.txt | while read url; do secretfinder -i "$url" -o cli | tee -a bug_bounty_report/$domain_Without_Protocol/recon/links/js_secrets-wide.txt; done

    echo ""
    echo "######################################################"
    echo "####### JS secrets and Endpoints Collected ###########"
    echo "######################################################"
    echo ""

    exit 0
fi