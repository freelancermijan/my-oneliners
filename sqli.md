### Params find

```
katana -u http://testphp.vulnweb.com -d 5 -ps -pss waybackarchive,commoncrawl,alienvault -f qurl | sed 's/=.*/=/' | sort -u | tee testphp.vulnweb.com.output.txt
```

### SQLi detect

```
sudo python3 ./lostsec.py -l testphp.vulnweb.com.output.txt -p payloads/xor.txt -t 5
```
