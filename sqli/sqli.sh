#!/usr/bin/env bash

# Function to display usage message
display_usage() {
    echo "Usage:"
    echo "     $0 -s http://example.com"
    echo ""
    echo "Options:"
    echo "  -h               Display this help message"
    echo "  -s               Single site scan"
    echo "  -sf              Fast scan for single site scan"
    echo "  -m               Multiple site scan"
    echo "  -i               Check if required tools are installed"
    echo ""
    echo "Required Tools:"
    echo "              https://github.com/projectdiscovery/subfinder
              https://github.com/freelancermijan/bsqli
              https://github.com/projectdiscovery/subfinder
              https://github.com/xnl-h4ck3r/waymore
              https://github.com/tomnomnom/qsreplace
              https://github.com/projectdiscovery/katana
              https://github.com/projectdiscovery/httpx"
    exit 0
}

# Function to check installed tools
check_tools() {
    tools=("sqlmap" "bsqli" "subfinder" "gf" "ghauri" "waymore" "katana" "qsreplace" "httpx")

    echo "Checking required tools:"
    for tool in "${tools[@]}"; do
        if command -v "$tool" &> /dev/null; then
            echo "$tool is installed at $(which $tool)"
        else
            echo "$tool is NOT installed or not in the PATH"
        fi
    done
}


# Check if help is requested
if [[ "$1" == "-h" ]]; then
    display_usage
    exit 0
fi

# Check if tool installation check is requested
if [[ "$1" == "-i" ]]; then
    check_tools
    exit 0
fi


if [[ "$1" == "-sf" ]]; then
    domain_Without_Protocol=$(echo "$2" | sed 's,http://,,;s,https://,,;s,www\.,,')

    mkdir -p bug_bounty_report/$domain_Without_Protocol/sqli/

    echo ""
    echo "=================================================================="
    echo "========== Fast scan for single site parameter finding ==========="
    echo "=================================================================="
    echo ""

    katana -u "$domain_Without_Protocol" -d 5 -ps -pss waybackarchive,commoncrawl,alienvault -sf fqdn -aff | qsreplace "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | sort -u>>bug_bounty_report/$domain_Without_Protocol/sqli/all.sf.parameters.txt

    cat bug_bounty_report/$domain_Without_Protocol/sqli/all.sf.parameters.txt | gf sqli | sed 's/\(=.*\)/=/' | sort -u | tee bug_bounty_report/$domain_Without_Protocol/sqli/sqli.sf.parameters.txt
    echo ""
    cat bug_bounty_report/$domain_Without_Protocol/sqli/sqli.sf.parameters.txt | wc -l

    echo ""
    echo "=================================================================="
    echo "====== Fast scan for single site parameter finding finished ======"
    echo "=================================================================="
    echo ""

    echo ""
    echo "=================================================================="
    echo "========= Fast scan for single site SQL Detecting ================"
    echo "=================================================================="
    echo ""
    bsqli --urls bug_bounty_report/$domain_Without_Protocol/sqli/sqli.sf.parameters.txt --payloads payloads/xor.txt --verbose --save bug_bounty_report/$domain_Without_Protocol/sqli/detected.sf.sql.urls.txt
    echo ""
    echo "=================================================================="
    echo "====== Fast scan for single site SQL Detecting finished =========="
    echo "=================================================================="
    echo ""
    cat bug_bounty_report/$domain_Without_Protocol/sqli/detected.sf.sql.urls.txt
    exit 0

fi

if [[ "$1" == "-s" ]]; then
    domain_Without_Protocol=$(echo "$2" | sed 's,http://,,;s,https://,,;s,www\.,,')

    mkdir -p bug_bounty_report/$domain_Without_Protocol/sqli/

    echo ""
    echo "=================================================================="
    echo "========== Single site parameter finding ========================="
    echo "=================================================================="
    echo ""

    waymore -i "$domain_Without_Protocol" -fc 301,302,303,304,307,308 -n -mode U | qsreplace "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | sort -u>>bug_bounty_report/$domain_Without_Protocol/sqli/all.parameters.txt

    cat bug_bounty_report/$domain_Without_Protocol/sqli/all.parameters.txt | gf sqli | sed 's/\(=.*\)/=/' | sort -u | tee bug_bounty_report/$domain_Without_Protocol/sqli/sqli.parameters.txt
    cat bug_bounty_report/$domain_Without_Protocol/sqli/sqli.parameters.txt | wc -l

    echo ""
    echo "=================================================================="
    echo "============= Single site parameter finding finished ============="
    echo "=================================================================="
    echo ""

    echo ""
    echo "=================================================================="
    echo "========= Single site SQL Detecting =============================="
    echo "=================================================================="
    echo ""
    bsqli --urls bug_bounty_report/$domain_Without_Protocol/sqli/sqli.parameters.txt --payloads payloads/xor.txt --verbose --save bug_bounty_report/$domain_Without_Protocol/sqli/detected.sql.urls.txt
    echo ""
    echo "=================================================================="
    echo "========= Single site SQL Detecting finished ====================="
    echo "=================================================================="
    echo ""
    cat bug_bounty_report/$domain_Without_Protocol/sqli/detected.sql.urls.txt
    exit 0

fi

if [[ "$1" == "-m" ]]; then
    domain_Without_Protocol=$(echo "$2" | sed 's,http://,,;s,https://,,;s,www\.,,')

    mkdir -p bug_bounty_report/$domain_Without_Protocol/sqli/
    echo ""
    echo "=================================================================="
    echo "========= Multiple site parameter finding ========================"
    echo "=================================================================="
    echo ""

    subfinder -d "$domain_Without_Protocol" -recursive -all -o bug_bounty_report/$domain_Without_Protocol/sqli/m_subdomains.txt

    httpx -l bug_bounty_report/$domain_Without_Protocol/sqli/m_subdomains.txt -td | grep -iE "apache|tomcat|nginx|iis|jetty|glassfish|litespeed" | grep -oP 'https?://(www\.)?[^\s]+' | sed -e 's~http://~~g' -e 's~https://~~g' -e 's~www\.~~g' | tee bug_bounty_report/$domain_Without_Protocol/sqli/alive.subdomains.txt

    cat bug_bounty_report/$domain_Without_Protocol/sqli/alive.subdomains.txt | while read domain; do waymore -i "$domain" -fc 301,302,303,304,307,308 -n -mode U | qsreplace "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | sort -u>> bug_bounty_report/$domain_Without_Protocol/sqli/m_all.parameters.txt; done

    cat bug_bounty_report/$domain_Without_Protocol/sqli/m_all.parameters.txt | gf sqli | sed 's/\(=.*\)/=/' | sort -u | tee bug_bounty_report/$domain_Without_Protocol/sqli/m_sqli.parameters.txt

    cat bug_bounty_report/$domain_Without_Protocol/sqli/m_sqli.parameters.txt | wc -l


    echo ""
    echo "=================================================================="
    echo "=========== Multiple site parameter finding finished ============="
    echo "=================================================================="
    echo ""

    echo ""
    echo "=================================================================="
    echo "========= Multiple site SQL Detecting ============================"
    echo "=================================================================="
    echo ""
    bsqli --urls bug_bounty_report/$domain_Without_Protocol/sqli/m_sqli.parameters.txt --payloads payloads/xor.txt --verbose --save bug_bounty_report/$domain_Without_Protocol/sqli/m_detected.sql.urls.txt
    echo ""
    echo "=================================================================="
    echo "========= Multiple site SQL Detecting finished ==================="
    echo "=================================================================="
    echo ""
    
    cat bug_bounty_report/$domain_Without_Protocol/sqli/m_detected.sql.urls.txt
    
    exit 0

fi
