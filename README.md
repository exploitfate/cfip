# Auto update CloudFlare IP addresses for nginx

[IP Ranges](https://www.cloudflare.com/ips/)

Thanks [Marek Bosman](https://marekbosman.com/site/automatic-update-of-cloudflare-ip-addresses-in-nginx/) for inspiration


## INSTALL ( *`root`* user )

### Clone repo
```
cd /opt && git clone https://github.com/exploitfate/cfip.git
chmod +x  /opt/cfip/update.sh
```

### Run script 

```
/opt/cfip/update.sh
```

### Add cron task ( *`root`* user )

```
0 0 * * * test -x /opt/cfip/update.sh && perl -e 'sleep int(rand(21600))' && /opt/cfip/update.sh
```