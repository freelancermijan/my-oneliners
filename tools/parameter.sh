#!/usr/bin/env bash

# Function to display usage message
display_usage() {
    echo "Usage:"
    echo "     $0 -s http://example.com"
    echo ""
    echo "Options:"
    echo "  -h               Display this help message"
    echo "  -m               Multiple site scan"
    echo "  -i               Check if required tools are installed"
    echo ""
    echo "Required Tools:"
    echo "              https://github.com/projectdiscovery/subfinder
              https://github.com/xnl-h4ck3r/waymore
              https://github.com/tomnomnom/qsreplace
              https://github.com/tomnomnom/gf
              https://github.com/projectdiscovery/httpx"
    exit 0
}

# Function to check installed tools
check_tools() {
    tools=( "subfinder" "gf" "waymore" "qsreplace" "httpx")

    echo "Checking required tools:"
    for tool in "${tools[@]}"; do
        if command -v "$tool" &> /dev/null; then
            echo "$tool is installed at $(which $tool)"
        else
            echo "$tool is NOT installed or not in the PATH"
        fi
    done
}

# Check if tool installation check is requested
if [[ "$1" == "-i" ]]; then
    check_tools
    exit 0
fi


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

    httpx -l bug_bounty_report/$domain_Without_Protocol/testable_params/all.subdomains.txt -mc 200,301,302,401,403,500 | sed -e 's~http://~~g' -e 's~https://~~g' -e 's~www\.~~g' | tee bug_bounty_report/$domain_Without_Protocol/testable_params/alive.subdomains.txt
 
    cat bug_bounty_report/$domain_Without_Protocol/testable_params/alive.subdomains.txt | wc -l

    echo ""
    cat bug_bounty_report/$domain_Without_Protocol/testable_params/alive.subdomains.txt | while read domain; do waymore -i "$domain" -n -mode U | qsreplace "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | sort -u>>bug_bounty_report/$domain_Without_Protocol/testable_params/all.parameters.txt; done

    cat bug_bounty_report/$domain_Without_Protocol/testable_params/all.parameters.txt | gf sqli | uro -b js css | tee bug_bounty_report/$domain_Without_Protocol/testable_params/only.sqli.parameters.txt

    cat bug_bounty_report/$domain_Without_Protocol/testable_params/only.sqli.parameters.txt | wc -l

    echo ""
    echo "=================================================================="
    echo "============ Multi site parameter finding finished ==============="
    echo "=================================================================="
    echo ""

    exit 0

fi
