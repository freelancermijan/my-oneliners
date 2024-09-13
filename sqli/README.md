## Dork

```
site:.in & filetype:php | filetype:asp | filetype:aspx | filetype:jsp | filetype:jspx & intext:"responsible disclosure"
```

## All Parameter Finding

```
subfinder -d "vulnweb.com" -recursive -all -silent | katana -d 5 -ps -pss waybackarchive,commoncrawl,alienvault -f qurl | qsreplace "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | sort -u | tee vulnweb.com.all.parameters.txt
```

## SQLi Parameters

```
subfinder -d "vulnweb.com" -recursive -all -silent | katana -d 5 -ps -pss waybackarchive,commoncrawl,alienvault -f qurl | gf sqli | qsreplace "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | sort -u | tee vulnweb.com.sql.parameters.txt
```

## Blind SQLi Detection

```
bsqli --urls vulnweb.com.sql.parameters.txt --payloads payloads/xor.txt --verbose --save vulnweb.com.detected.sql.parameters.txt
```
