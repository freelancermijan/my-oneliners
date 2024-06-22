### Subfinder

```
subfinder -d vulnweb.com -all -recursive -o vulnweb.com.subfinder.txt
```

### Sublist3r

```
sublist3r -d "vulnweb.com" -t 20 -v -o vulnweb.com.sublist3r.txt
```

### Assetfinder

```
assetfinder -subs-only vulnweb.com | tee assetfinder.vulnweb.com.txt
```
