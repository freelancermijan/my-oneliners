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
    echo "  -mf              Multiple site fast scan"
    echo "  -ml              Multiple list site scan (/directory/domains.txt)"
    echo "  -i               Check if required tools are installed"
    echo ""
    echo "Required Tools:"
    echo "              https://github.com/projectdiscovery/subfinder
              https://github.com/freelancermijan/bsqli
              https://github.com/projectdiscovery/subfinder
              https://github.com/xnl-h4ck3r/waymore
              https://github.com/tomnomnom/qsreplace
              https://github.com/projectdiscovery/katana
              https://github.com/s0md3v/uro
              https://github.com/projectdiscovery/httpx"
    exit 0
}

# Function to check installed tools
check_tools() {
    tools=("sqlmap" "bsqli" "subfinder" "gf" "uro" "ghauri" "waymore" "katana" "qsreplace" "httpx")

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

    katana -u "$domain_Without_Protocol" -d 5 -ps -pss waybackarchive,commoncrawl,alienvault -sf fqdn -f qurl -aff -ef js,css |  uro -f hasparams | qsreplace "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | sort -u >>bug_bounty_report/$domain_Without_Protocol/sqli/all.sf.parameters.txt

    cat bug_bounty_report/$domain_Without_Protocol/sqli/all.sf.parameters.txt | gf sqli | tee bug_bounty_report/$domain_Without_Protocol/sqli/sqli.sf.parameters.txt
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
    bsqli -u bug_bounty_report/$domain_Without_Protocol/sqli/sqli.sf.parameters.txt -p payloads/sleeps.txt -v -o bug_bounty_report/$domain_Without_Protocol/sqli/detected.sf.sql.urls.txt
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
    echo "=============== Single site SQLs finding ========================="
    echo "=================================================================="
    echo ""

    waymore -i "$domain_Without_Protocol" -fc 400,401,403,404,405,408 -n -mode U -oU bug_bounty_report/$domain_Without_Protocol/sqli/single.site.all.URLs.txt

    cat bug_bounty_report/$domain_Without_Protocol/sqli/single.site.all.URLs.txt | sed '/%/d' | grep -v -E 'js|css' | qsreplace -a "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | uro -f hasparams | gf sqli | tee bug_bounty_report/$domain_Without_Protocol/sqli/single.site.errors.parameter.txt

    cat bug_bounty_report/$domain_Without_Protocol/sqli/single.site.errors.parameter.txt | wc -l

    echo ""
    echo "================ Error SQLi ============================"

    esqli -l bug_bounty_report/$domain_Without_Protocol/sqli/single.site.errors.parameter.txt -p payloads/error.txt -t 10 --parallel -o bug_bounty_report/$domain_Without_Protocol/sqli/single.site.errors.detected.txt
    echo ""
    cat bug_bounty_report/$domain_Without_Protocol/sqli/single.site.errors.detected.txt
    cat bug_bounty_report/$domain_Without_Protocol/sqli/single.site.errors.detected.txt | wc -l

    echo "================ Blind SQLi ============================"
    cat bug_bounty_report/$domain_Without_Protocol/sqli/single.site.all.URLs.txt | sed '/%/d' | grep -v -E 'js|css' | qsreplace "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | uro -f hasparams | gf sqli | tee bug_bounty_report/$domain_Without_Protocol/sqli/single.site.no.value.parameter.txt
    cat bug_bounty_report/$domain_Without_Protocol/sqli/single.site.no.value.parameter.txt | wc -l

    bsqli -u bug_bounty_report/$domain_Without_Protocol/sqli/single.site.no.value.parameter.txt -p payloads/sleeps.txt -v -o bug_bounty_report/$domain_Without_Protocol/sqli/single.site.blinds.detected.txt -t 5

    cat bug_bounty_report/$domain_Without_Protocol/sqli/single.site.blinds.detected.txt
    echo "Blind Sqli"
    cat bug_bounty_report/$domain_Without_Protocol/sqli/single.site.blinds.detected.txt | wc -l
    echo "Error Sqli"
    cat bug_bounty_report/$domain_Without_Protocol/sqli/single.site.errors.detected.txt | wc -l


    echo ""
    echo "=================================================================="
    echo "============= Single site SQLs finding finished =================="
    echo "=================================================================="
    echo ""
    exit 0

fi

if [[ "$1" == "-m" ]]; then
    domain_Without_Protocol=$(echo "$2" | sed 's,http://,,;s,https://,,;s,www\.,,')

    mkdir -p bug_bounty_report/$domain_Without_Protocol/sqli/
    echo ""
    echo "=================================================================="
    echo "============== Multiple site SQLs finding ========================"
    echo "=================================================================="
    echo ""
    waymore -i "$domain_Without_Protocol" -fc 400,401,403,404,405,408 -mode U -oU bug_bounty_report/$domain_Without_Protocol/sqli/full.server.all.URLs.txt
    echo "================ Error SQLi ============================"
    cat bug_bounty_report/$domain_Without_Protocol/sqli/full.server.all.URLs.txt | sed '/%/d' | grep -v -E 'js|css' | qsreplace -a "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | uro -f hasparams | gf sqli | tee bug_bounty_report/$domain_Without_Protocol/sqli/full.server.errors.parameter.txt

    cat bug_bounty_report/$domain_Without_Protocol/sqli/full.server.errors.parameter.txt | wc -l

    echo ""

    esqli -l bug_bounty_report/$domain_Without_Protocol/sqli/full.server.errors.parameter.txt -p payloads/error.txt -t 10 --parallel -o bug_bounty_report/$domain_Without_Protocol/sqli/full.server.errors.detected.txt
    echo ""
    cat bug_bounty_report/$domain_Without_Protocol/sqli/full.server.errors.detected.txt
    cat bug_bounty_report/$domain_Without_Protocol/sqli/full.server.errors.detected.txt | wc -l

    echo "================ Blind SQLi ============================"
    cat bug_bounty_report/$domain_Without_Protocol/sqli/full.server.all.URLs.txt | sed '/%/d' | grep -v -E 'js|css' | qsreplace "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | uro -f hasparams | gf sqli | tee bug_bounty_report/$domain_Without_Protocol/sqli/full.server.no.value.parameter.txt
    cat bug_bounty_report/$domain_Without_Protocol/sqli/full.server.no.value.parameter.txt | wc -l

    bsqli -u bug_bounty_report/$domain_Without_Protocol/sqli/full.server.no.value.parameter.txt -p payloads/sleeps.txt -v -o bug_bounty_report/$domain_Without_Protocol/sqli/full.server.blinds.detected.txt -t 5

    cat bug_bounty_report/$domain_Without_Protocol/sqli/full.server.blinds.detected.txt
    echo "Blind Sqli"
    cat bug_bounty_report/$domain_Without_Protocol/sqli/full.server.blinds.detected.txt | wc -l
    echo "Error Sqli"
    cat bug_bounty_report/$domain_Without_Protocol/sqli/full.server.errors.detected.txt | wc -l


    echo ""
    echo "=================================================================="
    echo "============== Multiple site SQLs finding finished ==============="
    echo "=================================================================="
    echo ""
    exit 0

fi


if [[ "$1" == "-mf" ]]; then
    domain_Without_Protocol=$(echo "$2" | sed 's,http://,,;s,https://,,;s,www\.,,')

    mkdir -p bug_bounty_report/$domain_Without_Protocol/sqli/
    echo ""
    echo "=================================================================="
    echo "========= Multiple site parameter finding ========================"
    echo "=================================================================="
    echo ""

    subfinder -d "$domain_Without_Protocol" -recursive -all -o bug_bounty_report/$domain_Without_Protocol/sqli/mf_subdomains.txt

    httpx -l bug_bounty_report/$domain_Without_Protocol/sqli/mf_subdomains.txt -mc 200,301,302,401,403,500 | sed -e 's~http://~~g' -e 's~https://~~g' -e 's~www\.~~g' | tee bug_bounty_report/$domain_Without_Protocol/sqli/mf.alive.subdomains.txt


    katana -list bug_bounty_report/$domain_Without_Protocol/sqli/mf.alive.subdomains.txt -d 5 -ps -pss waybackarchive,commoncrawl,alienvault -sf fqdn -f qurl -aff -ef js,css |  uro -f hasparams | qsreplace "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | sort -u >>bug_bounty_report/$domain_Without_Protocol/sqli/all.mf.parameters.txt


    cat bug_bounty_report/$domain_Without_Protocol/sqli/all.mf.parameters.txt | gf sqli | tee bug_bounty_report/$domain_Without_Protocol/sqli/mf_sqli.parameters.txt

    cat bug_bounty_report/$domain_Without_Protocol/sqli/mf_sqli.parameters.txt | wc -l


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
    bsqli -u bug_bounty_report/$domain_Without_Protocol/sqli/mf_sqli.parameters.txt -p payloads/sleeps.txt -v -o bug_bounty_report/$domain_Without_Protocol/sqli/mf_detected.sql.urls.txt
    echo ""
    echo "=================================================================="
    echo "========= Multiple site SQL Detecting finished ==================="
    echo "=================================================================="
    echo ""
    
    cat bug_bounty_report/$domain_Without_Protocol/sqli/mf_detected.sql.urls.txt
    
    exit 0

fi


if [[ "$1" == "-ml" ]]; then
    domain_Without_Protocol=$(echo "$2" | sed 's,http://,,;s,https://,,;s,www\.,,')
    domain_save=$(cat "$2" | head -n 1)

    mkdir -p bug_bounty_report/$domain_save/sqli/


    echo "============ All URLs ============"
    echo ""
    cat $domain_Without_Protocol | while read domain; do waymore -i "$domain" -n -mode U -oU bug_bounty_report/$domain_save/sqli/multiple.site.all.urls.txt; done
    

    echo "============ Making params for error SQLi ============"
    echo ""

    cat bug_bounty_report/$domain_Without_Protocol/sqli/multiple.site.all.urls.txt | sed '/%/d' | grep -v -E 'js|css' | qsreplace -a "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | uro -f hasparams >> bug_bounty_report/$domain_save/sqli/multiple.site.all.error.urls.txt
    echo ""
    echo "Total error SQLi URLs:"
    cat bug_bounty_report/$domain_save/sqli/multiple.site.all.error.urls.txt | wc -l

    echo ""
    echo "============ Error SQLi start ================"

    esqli -l bug_bounty_report/$domain_save/sqli/multiple.site.all.error.urls.txt -p payloads/error.txt -t 10 --parallel -o bug_bounty_report/$domain_save/sqli/multiple.site.all.detect.error.urls.txt
    echo ""
    cat bug_bounty_report/$domain_save/sqli/multiple.site.all.detect.error.urls.txt | wc -l


    echo "============ Making params for Blind SQLi ============"
    echo ""

    cat bug_bounty_report/$domain_save/sqli/multiple.site.all.urls.txt | sed '/%/d' | grep -v -E 'js|css' | qsreplace "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | uro -f hasparams >> bug_bounty_report/$domain_save/sqli/multiple.site.all.blind.urls.txt
    echo ""
    echo "Total blind SQLi URLs:"
    cat bug_bounty_report/$domain_save/sqli/multiple.site.all.blind.urls.txt | wc -l


    echo ""
    echo "============ Blind SQLi start ================"
    bsqli -u bug_bounty_report/$domain_save/sqli/multiple.site.all.blind.urls.txt -p payloads/sleeps.txt -t 7 -v -o bug_bounty_report/$domain_save/sqli/multiple.site.all.detect.blind.urls.txt
    echo ""
    echo "Total Blind SQLi Detected:"
    cat bug_bounty_report/$domain_save/sqli/multiple.site.all.detect.blind.urls.txt | wc -l

    echo ""
    echo "Total Error SQLi Detected:"
    cat bug_bounty_report/$domain_save/sqli/multiple.site.all.detect.error.urls.txt | wc -l

    
    exit 0

fi
