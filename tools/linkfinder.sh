#!/usr/bin/env bash

# Function to display usage message
display_usage() {
    echo "Usage:"
    echo "     $0 -s http://example.com"
    echo ""
    echo "Options:"
    echo "  -h               Display this help message"
    echo "  -s               Single Domain Parameter Spidering (http://testphp.vulnweb.com)"
    echo "  -multi           Multi Domain Parameter Spidering (http://vulnweb.com)"
    echo "  -mass            Path of urls to Parameter Spidering(path/to/domains.txt)"
    echo ""
    echo "Required Tools:"
    echo "              https://github.com/tomnomnom/unfurl
              https://github.com/lc/gau
              https://github.com/tomnomnom/waybackurls
              https://github.com/xnl-h4ck3r/waymore
              https://github.com/projectdiscovery/katana
              https://github.com/tomnomnom/qsreplace
              https://github.com/m4ll0k/SecretFinder"
    exit 0
}

if [[ "$1" == "-h" ]]; then
    display_usage
    exit 0
fi

if [[ "$1" == "-s" ]]; then
    domain_Without_Protocol_save=$(echo "$2" | unfurl -u apexes)
    domain_Without_Protocol=$(echo "$2" | sed 's,http://,,;s,https://,,;s,www\.,,;')
    mkdir -p bug_bounty_report/$domain_Without_Protocol_save/recon/links

    echo "===================================================="
    echo "========= Single Domain URLs collecting ============"
    echo "===================================================="
    echo ""
    waybackurls -no-subs "$domain_Without_Protocol" | tee bug_bounty_report/$domain_Without_Protocol_save/recon/links/waybackurls.txt


    echo "===================================================="
    echo "========= Katana starting =========================="
    echo "===================================================="
    echo ""
    katana -u "$domain_Without_Protocol" -fs fqdn -rl 170 -timeout 5 -retry 2 -aff -d 5 -ef ttf,woff,svg,png,css -ps -pss waybackarchive,commoncrawl,alienvault -silent -o bug_bounty_report/$domain_Without_Protocol_save/recon/links/katana.txt

    waymore -i "$domain_Without_Protocol" -n -mode U -oU bug_bounty_report/$domain_Without_Protocol_save/recon/links/waymore.txt

    echo ""
    echo "===================================================="
    echo "=== Single Domain URLs collecting finished ========="
    echo "===================================================="

    cat bug_bounty_report/$domain_Without_Protocol_save/recon/links/waybackurls.txt bug_bounty_report/$domain_Without_Protocol_save/recon/links/waymore.txt bug_bounty_report/$domain_Without_Protocol_save/recon/links/katana.txt | sort -u | tee bug_bounty_report/$domain_Without_Protocol_save/recon/links/all_urls.txt

    cat bug_bounty_report/$domain_Without_Protocol_save/recon/links/all_urls.txt | unfurl path | sed -E 's/\/[^\/]+\.(png|jpg|gif|exe|com)//g' | grep -v "=" | sort -u | tee bug_bounty_report/$domain_Without_Protocol_save/recon/links/all_paths.txt

    echo "===================================================="
    echo "======= Single Domain Parameter collecting ========="
    echo "===================================================="
    echo ""

    cat bug_bounty_report/$domain_Without_Protocol_save/recon/links/all_urls.txt | qsreplace "FUZZ" | grep "FUZZ" | sort -u >> bug_bounty_report/$domain_Without_Protocol_save/recon/links/all_parameters.txt

    cat bug_bounty_report/$domain_Without_Protocol_save/recon/links/all_urls.txt | qsreplace -a "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | sort -u | tee bug_bounty_report/$domain_Without_Protocol_save/recon/links/all_parameters_with_value.txt

    cat bug_bounty_report/$domain_Without_Protocol_save/recon/links/all_parameters.txt | wc -l
    echo ""
    echo "===================================================="
    echo "============= Single Domain Parameters ============="
    echo "===================================================="


    echo ""
    echo "===================================================="
    echo "================== JS Links Collecting ============="
    echo "===================================================="
    echo ""
    cat bug_bounty_report/$domain_Without_Protocol_save/recon/links/all_urls.txt | grep -E --text "\.js$" | sort -u | tee bug_bounty_report/$domain_Without_Protocol_save/recon/links/js_links.txt
    cat bug_bounty_report/$domain_Without_Protocol_save/recon/links/js_links.txt | wc -l
    echo ""
    echo "===================================================="
    echo "========== JS Links Collecting finished ============"
    echo "===================================================="
    echo ""


    echo ""
    echo "===================================================="
    echo "####### JS secrets and Endpoints Collecting ###########"
    echo "===================================================="
    echo ""

    nuclei -l bug_bounty_report/$domain_Without_Protocol_save/recon/links/js_links.txt -t ~/nuclei-templates/ -tags exposure -o bug_bounty_report/$domain_Without_Protocol_save/recon/links/js_secrets.txt


    cat bug_bounty_report/$domain_Without_Protocol_save/recon/links/js_links.txt | while read url; do secretfinder -i "$url" -o cli | tee -a bug_bounty_report/$domain_Without_Protocol_save/recon/links/js_secrets.txt; done

    echo ""
    echo "===================================================="
    echo "####### JS secrets and Endpoints Collected ###########"
    echo "===================================================="
    echo ""
    exit 0

fi

if [[ "$1" == "-multi" ]]; then
    domain_Without_Protocol_save=$(echo "$2" | unfurl -u apexes)
    domain_Without_Protocol=$(echo "$2" | sed 's,http://,,;s,https://,,;s,www\.,,;')
    mkdir -p bug_bounty_report/$domain_Without_Protocol_save/recon/links

    echo "===================================================="
    echo "======= Multiple Domain URLs collecting ============"
    echo "===================================================="
    echo ""
    gau "$domain_Without_Protocol" --subs --providers wayback,commoncrawl,otx,urlscan --threads 70 --verbose --o bug_bounty_report/$domain_Without_Protocol_save/recon/links/gau-multi-domain.txt

    waybackurls "$domain_Without_Protocol" | tee bug_bounty_report/$domain_Without_Protocol_save/recon/links/waybackurls-multi-domain.txt

    katana -u "$domain_Without_Protocol" -rl 170 -timeout 5 -retry 2 -aff -d 4 -ef ttf,woff,svg,png,css -ps -pss waybackarchive,commoncrawl,alienvault -silent -o bug_bounty_report/$domain_Without_Protocol_save/recon/links/katana-multi-domain.txt

    waymore -i "$domain_Without_Protocol" -mode U -oU bug_bounty_report/$domain_Without_Protocol_save/recon/links/waymore-multi-domain.txt

    echo ""
    echo "===================================================="
    echo "=== Multiple Domain URLs collecting finished ======="
    echo "===================================================="

    cat bug_bounty_report/$domain_Without_Protocol_save/recon/links/gau-multi-domain.txt bug_bounty_report/$domain_Without_Protocol_save/recon/links/waybackurls-multi-domain.txt bug_bounty_report/$domain_Without_Protocol_save/recon/links/waymore-multi-domain.txt bug_bounty_report/$domain_Without_Protocol_save/recon/links/katana-multi-domain.txt | sort -u | tee bug_bounty_report/$domain_Without_Protocol_save/recon/links/all_urls-multi-domain.txt

    
    cat bug_bounty_report/$domain_Without_Protocol_save/recon/links/all_urls-multi-domain.txt | unfurl path | sed -E 's/\/[^\/]+\.(png|jpg|gif|exe|com)//g' | grep -v "=" | sort -u | tee bug_bounty_report/$domain_Without_Protocol_save/recon/links/all_paths-multi-domain.txt

    echo "===================================================="
    echo "===== Multiple Domain Parameter collecting ========="
    echo "===================================================="
    echo ""
    # cat bug_bounty_report/$domain_Without_Protocol_save/recon/links/all_urls-multi-domain.txt | sort -u | grep "=" | egrep -iv ".(jpg|jpeg|gif|css|tif|tiff|png|ttf|woff|woff2|ico|pdf|svg|txt|js)" | tee bug_bounty_report/$domain_Without_Protocol_save/recon/links/all_parameters-multi-domain.txt

    cat bug_bounty_report/$domain_Without_Protocol_save/recon/links/all_urls-multi-domain.txt | qsreplace "FUZZ" | grep "FUZZ" | sort -u >> bug_bug_bounty_report/$domain_Without_Protocol_save/recon/links/all_parameters_multi_domain.txt

    cat bug_bounty_report/$domain_Without_Protocol_save/recon/links/all_urls.txt | qsreplace -a "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | sort -u | tee bug_bounty_report/$domain_Without_Protocol_save/recon/links/all_parameters_multi_domain_with_value.txt

    cat bug_bug_bounty_report/$domain_Without_Protocol_save/recon/links/all_parameters_multi_domain.txt | wc -l
    echo ""
    echo "===================================================="
    echo "=== Multiple Domain Parameters Collecting finished=="
    echo "===================================================="


    echo ""
    echo "===================================================="
    echo "################## JS Links Collecting ###############"
    echo "===================================================="
    echo ""

    cat bug_bounty_report/$domain_Without_Protocol/recon/links/all_urls-multi-domain.txt | grep -E --text "\.js$" | sort -u | tee bug_bounty_report/$domain_Without_Protocol/recon/links/js_links-multi-domain.txt
    cat bug_bounty_report/$domain_Without_Protocol/recon/links/js_links-multi-domain.txt | wc -l
    echo ""
    echo "===================================================="
    echo "########### JS Links Collecting finished #############"
    echo "===================================================="
    echo ""


    echo ""
    echo "===================================================="
    echo "####### JS secrets and Endpoints Collecting ##########"
    echo "===================================================="
    echo ""

    nuclei -l bug_bounty_report/$domain_Without_Protocol_save/recon/links/js_links-multi-domain.txt -t ~/nuclei-templates/ -tags exposure -o bug_bounty_report/$domain_Without_Protocol_save/recon/links/js_secrets-multi-domain.txt


    cat bug_bounty_report/$domain_Without_Protocol/recon/links/js_links-multi-domain.txt | while read url; do secretfinder -i "$url" -o cli | tee -a bug_bounty_report/$domain_Without_Protocol/recon/links/js_secrets-multi-domain.txt; done

    echo ""
    echo "===================================================="
    echo "####### JS secrets and Endpoints Collected ###########"
    echo "===================================================="
    echo ""

    exit 0
fi


if [[ "$1" == "-mass" ]]; then
    domain_Without_Protocol=$(head -n 1 "$2" | unfurl -u apexes)
    allurls="$2"
    mkdir -p bug_bounty_report/$domain_Without_Protocol/recon/links

    echo "===================================================="
    echo "======== Massive Domain URLs collecting ============"
    echo "===================================================="
    echo ""
    cat $allurls | while read subdomains; do waybackurls -no-subs "$subdomains" | tee -a bug_bounty_report/$domain_Without_Protocol/recon/links/waybackurls-mass.txt; done

    cat $allurls | while read subdomains; do waymore -i "$subdomains" -n -mode U | tee -a bug_bounty_report/$domain_Without_Protocol/recon/links/waymore-mass.txt; done

    cat $allurls | while read subdomains; do katana -u "$subdomains" -fs fqdn -rl 170 -timeout 5 -retry 2 -aff -d 4 -ef ttf,woff,svg,png,css -ps -pss waybackarchive,commoncrawl,alienvault -silent -o bug_bounty_report/$domain_Without_Protocol/recon/links/katana-mass.txt; done



    echo ""
    echo "===================================================="
    echo "=== Massive Domain URLs collecting finished ========"
    echo "===================================================="

    cat bug_bounty_report/$domain_Without_Protocol/recon/links/waybackurls-mass.txt bug_bounty_report/$domain_Without_Protocol/recon/links/waymore-mass.txt bug_bounty_report/$domain_Without_Protocol/recon/links/katana-mass.txt | sort -u | tee bug_bounty_report/$domain_Without_Protocol/recon/links/all_mass_urls.txt

    cat bug_bounty_report/$domain_Without_Protocol/recon/links/all_mass_urls.txt | unfurl path | sed -E 's/\/[^\/]+\.(png|jpg|gif|exe|com|htm|js|xml|txt|xyz|css)//g' | grep -v "=" | tr '/' '\n' | grep -v ':$' | sort -u | tee bug_bounty_report/$domain_Without_Protocol/recon/links/all_mass_paths.txt

    echo "===================================================="
    echo "======= Mass Domain Parameter collecting ==========="
    echo "===================================================="
    echo ""
    # cat bug_bounty_report/$domain_Without_Protocol/recon/links/all_mass_urls.txt | sort -u | grep "=" | grep -Piv ".(jpg|jpeg|gif|css|tif|tiff|png|ttf|woff|woff2|ico|pdf|svg|txt|js)" | tee bug_bounty_report/$domain_Without_Protocol/recon/links/all_mass_parameters.txt

    cat bug_bounty_report/$domain_Without_Protocol/recon/links/all_mass_urls.txt | qsreplace "FUZZ" | grep "FUZZ" | sort -u >> bug_bounty_report/$domain_Without_Protocol/recon/links/all_mass_parameters.txt

    cat bug_bounty_report/$domain_Without_Protocol/recon/links/all_mass_urls.txt | qsreplace -a "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | sort -u | tee bug_bounty_report/$domain_Without_Protocol/recon/links/all_mass_parameters_with_value.txt


    # cat $allurls | while read params; do paramspider -d "$params" -s | grep "http" | tee -a bug_bounty_report/$domain_Without_Protocol/recon/links/all_mass_parameters-paramfinder.txt; done
    

    cat bug_bounty_report/$domain_Without_Protocol/recon/links/all_mass_parameters.txt | wc -l
    echo ""
    echo "===================================================="
    echo "============= Mass Domain Parameters ==============="
    echo "===================================================="

    # collecting all js files at onece
    cat bug_bounty_report/$domain_Without_Protocol/recon/links/all_mass_urls.txt | grep -E --text "\.js$" | sort -u | tee bug_bounty_report/$domain_Without_Protocol/recon/links/js_mass_links.txt
    cat bug_bounty_report/$domain_Without_Protocol/recon/links/js_mass_links.txt | wc -l

    echo ""
    echo "===================================================="
    echo "####### JS secrets and Endpoints Collecting ###########"
    echo "===================================================="
    echo ""

    nuclei -l bug_bounty_report/$domain_Without_Protocol_save/recon/links/js_mass_links.txt -t ~/nuclei-templates/ -tags exposure -o bug_bounty_report/$domain_Without_Protocol_save/recon/links/js_mass_secrets.txt


    cat bug_bounty_report/$domain_Without_Protocol/recon/links/js_mass_links.txt | while read url; do secretfinder -i "$url" -o cli | tee -a bug_bounty_report/$domain_Without_Protocol/recon/links/js_mass_secrets.txt; done

    echo ""
    echo "===================================================="
    echo "####### JS secrets and Endpoints Collected ###########"
    echo "===================================================="
    echo ""
    exit 0

fi