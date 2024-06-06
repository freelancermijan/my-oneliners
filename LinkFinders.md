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

# Multi Domain URLs find

### Waymore

```
waymore -i "vulnweb.com" -mode U | tee vulnweb.com.txt
```

### Waybackurls

```
waybackurls vulnweb.com | tee vulnweb.com.txt
````

### Gau

```
gau --subs vulnweb.com --providers wayback,commoncrawl,otx,urlscan --threads 70 | tee urls.txt
```
