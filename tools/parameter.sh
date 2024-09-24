#!/usr/bin/env bash

# Function to display usage message
display_usage() {
    echo "Usage:"
    echo "     $0 -s http://example.com"
    echo ""
    echo "Options:"
    echo "  -h               Display this help message"
    echo "  -m               Multiple site scan"
    echo ""
    echo "Required Tools:"
    echo "              https://github.com/projectdiscovery/subfinder
              https://github.com/xnl-h4ck3r/waymore
              https://github.com/tomnomnom/qsreplace"
    exit 0
}

if [[ "$1" == "-h" ]]; then
    display_usage
    exit 0
fi


if [[ "$1" == "-m" ]]; then
    domain_Without_Protocol=$(echo "$2" | sed 's,http://,,;s,https://,,;s,www\.,,;')

    mkdir -p bug_bounty_report/$domain_Without_Protocol/testable_params/

    echo ""
    echo "=================================================================="
    echo "=============== Multi site parameter finding ====================="
    echo "=================================================================="
    echo ""

    subfinder -d "$domain_Without_Protocol" -recursive -all -o bug_bounty_report/$domain_Without_Protocol/testable_params/all.subdomains.txt

    httpx -l bug_bounty_report/$domain_Without_Protocol/testable_params/all.subdomains.txt -td | grep -iE "apache|tomcat|nginx|iis|jetty|glassfish|litespeed" | grep -oP 'http://[^\s]*' | sed -e 's~http://~~g' -e 's~https://~~g' -e 's~www\.~~g' | tee bug_bounty_report/$domain_Without_Protocol/testable_params/alive.subdomains.txt
 
    cat bug_bounty_report/$domain_Without_Protocol/testable_params/alive.subdomains.txt | wc -l

    echo ""
    cat bug_bounty_report/$domain_Without_Protocol/testable_params/alive.subdomains.txt | while read domain; do waymore -i "$domain" -n -mode U | qsreplace "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | sort -u>>bug_bounty_report/$domain_Without_Protocol/testable_params/all.parameters.txt; done

    cat bug_bounty_report/$domain_Without_Protocol/testable_params/all.parameters.txt | gf sqli | sed 's/\(=.*\)/=/' | sort -u | tee bug_bounty_report/$domain_Without_Protocol/testable_params/only.sqli.parameters.txt

    cat bug_bounty_report/$domain_Without_Protocol/testable_params/only.sqli.parameters.txt | wc -l

    echo ""
    echo "=================================================================="
    echo "============ Multi site parameter finding finished ==============="
    echo "=================================================================="
    echo ""

    exit 0

fi
