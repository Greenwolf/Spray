Domain Password Sprayer v1.1 <br />
<br />
Author: Greenwolf \<jwilkin@trustwave.com><br />
<br />
This script will password spray a target over a period of time<br />
It requires password policy as input so accounts are not locked out<br />
<br />
Accompanying this script are a series of hand crafted password files for multiple languages<br />
These have been crafted from the most common active directory passwords in various languages<br />
and all fit in the complex (1 Upper, 1 lower, 1 digit) catagory. 
<br />
To password spray SMB
<br />
Useage: spray.sh -smb &lt;targetIP> &lt;usernameList> &lt;passwordList> &lt;AttemptsPerLockoutPeriod> &lt;LockoutPeriodInMinutes> &lt;DOMAIN><br />
Example: spray.sh -smb 192.168.0.1 users.txt passwords.txt 1 35 CORPORATION<br />
<br />
To password spray an OWA Portal 
<br />
Useage: spray.sh -owa &lt;targetIP> &lt;usernameList> &lt;passwordList> &lt;AttemptsPerLockoutPeriod> &lt;LockoutPeriodInMinutes> &lt;RequestsFile><br />
Example: spray.sh -owa 192.168.0.1 users.txt passwords.txt 1 35 post-request.txt<br />
<br />
To password spray a Lync Service 
<br />
Useage: spray.sh -lync &lt;targetIP> &lt;usernameList> &lt;passwordList> &lt;AttemptsPerLockoutPeriod> &lt;LockoutPeriodInMinutes><br />
Example: spray.sh -lync https://lyncdiscover.company.com/ users.txt passwords.txt 1 35<br />
Example: spray.sh -lync https://lyncweb.company.com/Autodiscover/AutodiscoverService.svc/root/oauth/user users.txt passwords.txt 1 35<br />
<br />
It is also possible to update the supplied 2016/2017 password list to the current year<br />
Useage: spray.sh -passupdate &lt;passwordList><br />
Example: spray.sh -passupdate passwords.txt<br />
<br />
An optional company name can also be provided to add to the list:<br />
Useage: spray.sh -passupdate &lt;passwordList> &lt;CompanyName><br />
Example: spray.sh -passupdate passwords.txt "Trustwave"<br />
<br />
A username list can also be generated from a list of common names:<br />
Useage: spray.sh -genusers &lt;firstnames> &lt;lastnames> "&lt;&lt;fi>&lt;li>&lt;fn>&lt;ln>>"<br />
Example: spray.sh -genusers english-first-1000.txt english-last-1000.txt "&lt;fi>&lt;ln>"<br />
Example: spray.sh -genusers english-first-1000.txt english-last-1000.txt "&lt;fn>.&lt;ln>"<br />
<br />