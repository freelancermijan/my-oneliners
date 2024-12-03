#!/usr/bin/env bash

# Function to display usage message
display_usage() {
    echo "Usage:"
    echo "     $0 -s http://example.com"
    echo ""
    echo "Options:"
    echo "  -h               Display this help message"
    echo "  -s               Single domain"
    echo "  -m               Multiple domain"
    echo "  -i               Check if required tools are installed"
    exit 0
}

# Function to check installed tools
check_tools() {
    tools=("katana" "subfinder" "sublist3r" "gf" "anew" "qsreplace" "httpx" "uro" "urlfinder")

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

if [[ "$1" == "-s" ]]; then

    domain_Without_Protocol=$(echo "$2" | sed 's,http://,,;s,https://,,;s,www\.,,;')
    base_dir="bug_bounty_report/$domain_Without_Protocol/singleDomain/recon/urls"
    sudo mkdir -p "$base_dir"
    sudo chmod -R 777 bug_bounty_report/$domain_Without_Protocol

    katana -u "$domain_Without_Protocol" -f qurl -d 5 -ps -pss waybackarchive,commoncrawl,alienvault -duc -fs fqdn -o $base_dir/1_AllUrls.txt

    # urlfinder -d "$domain_Without_Protocol" -all -o $base_dir/1_AllUrls.txt

    cat $base_dir/1_AllUrls.txt | grep -E '\.(xml|config|db|dbconfig|ini)$' | anew $base_dir/2_SensitiveUrls.txt

    cat $base_dir/1_AllUrls.txt | grep -Ev 'js|json|css' | gf xss | qsreplace "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | uro -o $base_dir/3_XssUrls.txt

    cat $base_dir/1_AllUrls.txt | grep -Ev 'js|json|css' | gf sqli | qsreplace "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | uro -o $base_dir/4_SqliUrls.txt

    cat $base_dir/1_AllUrls.txt | qsreplace "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | grep -E ".php|.asp|.aspx|.jspx|.jsp" | anew $base_dir/4_1_SqliUrls.txt

    cat $base_dir/4_SqliUrls.txt $base_dir/4_1_SqliUrls.txt | anew $base_dir/4_2_SqliUrls.txt

    cat $base_dir/1_AllUrls.txt | grep -Ev 'js|json|css' | gf redirect | qsreplace "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | uro -o $base_dir/5_OpenRedirectUrls.txt

    cat $base_dir/1_AllUrls.txt | grep -Ev 'js|json|css' | gf lfi | qsreplace "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | uro -o $base_dir/6_LfiUrls.txt

    cat $base_dir/1_AllUrls.txt | grep -Ev 'js|json|css' | qsreplace "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | uro -o $base_dir/7_WithoutValueAllUrls.txt

    cat $base_dir/1_AllUrls.txt | grep -Ev 'js|json|css' | qsreplace -a "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | uro -o $base_dir/8_WithValueAllUrls.txt

    cat $base_dir/1_AllUrls.txt  | grep -E 'js|json' | anew $base_dir/9_jsLinks.txt

    cat $base_dir/7_WithoutValueAllUrls.txt
    echo ""

    echo "============================"
    echo "All files collected:"
    echo ""

    allUrls=$(cat $base_dir/1_AllUrls.txt | wc -l)
    echo "Total urls found ($allUrls):  $base_dir/1_AllUrls.txt"
    echo ""

    sensitive=$(cat $base_dir/2_SensitiveUrls.txt | wc -l)
    echo "Total sensitive urls ($sensitive):  $base_dir/2_SensitiveUrls.txt"
    echo ""

    xssfound=$(cat $base_dir/3_XssUrls.txt | wc -l)
    echo "Total XSS urls ($xssfound):  $base_dir/3_XssUrls.txt"
    echo ""

    sqlifound=$(cat $base_dir/4_2_SqliUrls.txt | wc -l)
    echo "Total SQLi urls ($sqlifound):: $base_dir/4_2_SqliUrls.txt"
    echo ""

    orfound=$(cat $base_dir/5_OpenRedirectUrls.txt | wc -l)
    echo "Total Open Redirect urls ($orfound): $base_dir/5_OpenRedirectUrls.txt"
    echo ""

    lfifound=$(cat $base_dir/6_LfiUrls.txt | wc -l)
    echo "Total Lfi urls ($lfifound): $base_dir/6_LfiUrls.txt"
    echo ""

    paramswithoutvalue=$(cat $base_dir/7_WithoutValueAllUrls.txt | wc -l)
    echo "Total parameters without value ($paramswithoutvalue): $base_dir/7_WithoutValueAllUrls.txt"
    echo ""

    params=$(cat $base_dir/8_WithValueAllUrls.txt | wc -l)
    echo "Total parameters with value ($params): $base_dir/8_WithValueAllUrls.txt"
    echo ""
    
    jslinks=$(cat $base_dir/9_jsLinks.txt | wc -l)
    echo "Total JS Links ($jslinks): $base_dir/9_jsLinks.txt"
    echo ""

    sudo chmod -R 777 bug_bounty_report/$domain_Without_Protocol
    exit 0
    
fi


if [[ "$1" == "-m" ]]; then

    domain_Without_Protocol=$(echo "$2" | sed 's,http://,,;s,https://,,;s,www\.,,;')
    base_dir="bug_bounty_report/$domain_Without_Protocol/subDomain/recon/urls"
    sudo mkdir -p "$base_dir"
    sudo chmod -R 777 $base_dir

    subfinder -d "$domain_Without_Protocol" -recursive -all -o $base_dir/1_subdomains_subfinder.txt

    sublist3r -d "$domain_Without_Protocol" -t 10 -o $base_dir/2_subdomains_sublist3r.txt

    cat $base_dir/1_subdomains_subfinder.txt $base_dir/2_subdomains_sublist3r.txt | anew $base_dir/3_unique_subdomains.txt

    httpx -l $base_dir/3_unique_subdomains.txt -o $base_dir/4_Live_subdomains.txt

    urlfinder -list "$base_dir/4_Live_subdomains.txt" -all -o $base_dir/4_0_AllUrls.txt

    katana -list $base_dir/4_Live_subdomains.txt -d 5 -ps -pss waybackarchive,commoncrawl,alienvault -duc -fs fqdn -o $base_dir/5_0_0_All_Urls.txt

    cat $base_dir/4_0_AllUrls.txt $base_dir/5_0_0_All_Urls.txt | anew $base_dir/5_All_Urls.txt

    cat $base_dir/5_All_Urls.txt | grep -E '\.(xml|config|db|dbconfig|ini)$' | anew $base_dir/6_SensitiveUrls.txt

    cat $base_dir/5_All_Urls.txt | grep -Ev 'js|json|css' | gf xss | qsreplace "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | anew $base_dir/7_XssUrls.txt

    cat $base_dir/5_All_Urls.txt | grep -Ev 'js|json|css' | gf sqli | qsreplace "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | anew $base_dir/8_SqliUrls.txt

    cat $base_dir/5_All_Urls.txt | qsreplace "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | grep -E ".php|.asp|.aspx|.jspx|.jsp" | anew $base_dir/8_1_SqliUrls.txt


    cat $base_dir/8_SqliUrls.txt $base_dir/8_1_SqliUrls.txt | anew $base_dir/8_2_SqliUrls.txt

    cat $base_dir/5_All_Urls.txt | grep -Ev 'js|json|css' | gf redirect | qsreplace "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | anew $base_dir/9_OpenRedirectUrls.txt

    cat $base_dir/5_All_Urls.txt | grep -Ev 'js|json|css' | gf lfi | qsreplace "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | anew $base_dir/10_LfiUrls.txt

    cat $base_dir/5_All_Urls.txt | grep -Ev 'js|json|css' | qsreplace "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | anew $base_dir/11_WithoutValueAllUrls.txt

    cat $base_dir/5_All_Urls.txt | grep -Ev 'js|json|css' | qsreplace -a "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | anew $base_dir/12_WithValueAllUrls.txt

    cat $base_dir/5_All_Urls.txt  | grep -E 'js|json' | anew $base_dir/13_jsLinks.txt

    cat $base_dir/11_WithoutValueAllUrls.txt
    echo ""

    echo "============================"
    echo "All files collected:"
    echo ""


    allsubdomains=$(cat $base_dir/4_Live_subdomains.txt | wc -l)
    echo "Total live subdomains found ($allsubdomains):  $base_dir/4_Live_subdomains.txt"
    echo ""


    allUrls=$(cat $base_dir/5_All_Urls.txt | wc -l)
    echo "Total urls found ($allUrls):  $base_dir/5_All_Urls.txt"
    echo ""

    sensitive=$(cat $base_dir/6_SensitiveUrls.txt | wc -l)
    echo "Total sensitive urls ($sensitive):  $base_dir/6_SensitiveUrls.txt"
    echo ""

    xssfound=$(cat $base_dir/7_XssUrls.txt | wc -l)
    echo "Total XSS urls ($xssfound):  $base_dir/7_XssUrls.txt"
    echo ""

    sqlifound=$(cat $base_dir/8_2_SqliUrls.txt | wc -l)
    echo "Total SQLi urls ($sqlifound):: $base_dir/8_2_SqliUrls.txt"
    echo ""

    orfound=$(cat $base_dir/9_OpenRedirectUrls.txt | wc -l)
    echo "Total Open Redirect urls ($orfound): $base_dir/9_OpenRedirectUrls.txt"
    echo ""

    lfifound=$(cat $base_dir/10_LfiUrls.txt | wc -l)
    echo "Total Lfi urls ($lfifound): $base_dir/10_LfiUrls.txt"
    echo ""

    paramswithoutvalue=$(cat $base_dir/11_WithoutValueAllUrls.txt | wc -l)
    echo "Total parameters without value ($paramswithoutvalue): $base_dir/11_WithoutValueAllUrls.txt"
    echo ""

    params=$(cat $base_dir/12_WithValueAllUrls.txt | wc -l)
    echo "Total parameters with value ($params): $base_dir/12_WithValueAllUrls.txt"
    echo ""

    jslinks=$(cat $base_dir/13_jsLinks.txt | wc -l)
    echo "Total JS Links ($jslinks): $base_dir/13_jsLinks.txt"
    echo ""

    sudo chmod -R 777 bug_bounty_report/$domain_Without_Protocol
    exit 0
    
fi