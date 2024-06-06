# Single Domain URLs Finding

### Waymore

```
waymore -i "testphp.vulnweb.com" -n -mode U | tee testphp.vulnweb.com.txt
```

### waybackurls

```
waybackurls -no-subs testphp.vulnweb.com
```

### Gau

```
gau testphp.vulnweb.com --providers wayback,commoncrawl,otx,urlscan --threads 70 | tee urls.txt
```
