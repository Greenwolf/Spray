# Spray

A Password Spraying tool for Active Directory Credentials by Jacob Wilkin(Greenwolf)

## Getting Started

These instructions will show you the requirements for and how to use Spray.

### Prerequisites

All requirements come preinstalled on Kali Linux, to run on other flavors or Mac
just make sure curl(owa & lync) and rpcclient(smb) are installed using apt-get or brew.

```
rpcclient
curl
```

## Using Spray

This script will password spray a target over a period of time
It requires password policy as input so accounts are not locked out

Accompanying this script are a series of hand crafted password files for 
multiple languages. These have been crafted from the most common active 
directory passwords in various languages and all fit in the complex 
(1 Upper, 1 lower, 1 digit) catagory. 

### SMB

To password spray a SMB Portal, a userlist, password list, attempts 
per lockout period, lockout period length and the domain must be provided

```
Useage: spray.sh -smb <targetIP> <usernameList> <passwordList> <AttemptsPerLockoutPeriod> <LockoutPeriodInMinutes> <DOMAIN>
Example: spray.sh -smb 192.168.0.1 users.txt passwords.txt 1 35 SPIDERLABS
Optionally Skip Username%Username Spray: spray.sh -smb 192.168.0.1 users.txt passwords.txt 1 35 SPIDERLABS skipuu
```

### OWA

To password spray an OWA portal, a file must be created of the POST 
request with the Username: sprayuser@domain.com, and Password: spraypassword

```
Useage: spray.sh -owa <targetIP> <usernameList> <passwordList> <AttemptsPerLockoutPeriod> <LockoutPeriodInMinutes> <RequestsFile>
Example: spray.sh -owa 192.168.0.1 users.txt passwords.txt 1 35 post-request.txt
```

### Lync

To password spray a lync service, a lync autodiscover url or a url that 
returns the www-authenticate header must be provided along with a list of email addresses

```
Useage: spray.sh -lync <targetIP> <usernameList> <passwordList> <AttemptsPerLockoutPeriod> <LockoutPeriodInMinutes>
Example: spray.sh -lync https://lyncdiscover.spiderlabs.com/ users.txt passwords.txt 1 35
Example: spray.sh -lync https://lyncweb.spiderlabs.com/Autodiscover/AutodiscoverService.svc/root/oauth/user users.txt passwords.txt 1 35
```

### CISCO Web VPN

To password spray a CISCO Web VPN service, a target portal or server 
hosting a portal must be provided

```
Useage: spray.sh -cisco <targetURL> <usernameList> <passwordList> <AttemptsPerLockoutPeriod> <LockoutPeriodInMinutes>
Example: spray.sh -ciso 192.168.0.1 usernames.txt passwords.txt 1 35
```

### Password List Update

It is also possible to update the supplied 2016/2017 
password list to the current year

```
Useage: spray.sh -passupdate <passwordList>
Example: spray.sh -passupdate passwords.txt
```

An optional company name can also be provided to add to the list

```
Useage: spray.sh -passupdate <passwordList> <CompanyName>
Example: spray.sh -passupdate passwords.txt Spiderlabs
```

### Username generation

A username list can also be generated from a list of common names

```
Useage: spray.sh -genusers <firstnames> <lastnames> "<<fi><li><fn><ln>>"
Example: spray.sh -genusers english-first-1000.txt english-last-1000.txt "<fi><ln>"
Example: spray.sh -genusers english-first-1000.txt english-last-1000.txt "<fn>.<ln>"
```

## Authors

* [**Jacob Wilkin**](https://github.com/Greenwolf) - *Research and Development* - [Trustwave SpiderLabs](https://github.com/SpiderLabs)

## Donation
If this tool has been useful for you, feel free to thank me by buying me a coffee :)

[![Coffee](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/Greenwolf)

## License

Spray
Created by Jacob Wilkin
Copyright (C) 2017 Trustwave Holdings, Inc.
 
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

## Acknowledgments

* Thanks to insidetrust for their great [statistically likely usernames](https://github.com/insidetrust/statistically-likely-usernames) project which I have included in the name-lists folder
* Thanks to [iditabad](https://github.com/iditabad) and [vortexau](https://github.com/vortexau) for their pull request contributions to the project.

