#!/bin/bash
#============================================================
# Script: criarusuario.sh
# Description: Manages SSH accounts and OpenVPN configurations
# Author: @pphdev
#============================================================

# Read IP from /etc/IP
IP=$(cat /etc/IP)
cor1='\033[41;1;37m'
cor2='\033[44;1;37m'
scor='\033[0m'

# Function to generate client.ovpn
newclient() {
    cp /etc/openvpn/client-common.txt ~/$1.ovpn
    echo "<ca>" >>~/$1.ovpn
    cat /etc/openvpn/easy-rsa/pki/ca.crt >>~/$1.ovpn
    echo "</ca>" >>~/$1.ovpn
    echo "<cert>" >>~/$1.ovpn
    cat /etc/openvpn/easy-rsa/pki/issued/$1.crt >>~/$1.ovpn
    echo "</cert>" >>~/$1.ovpn
    echo "<key>" >>~/$1.ovpn
    cat /etc/openvpn/easy-rsa/pki/private/$1.key >>~/$1.ovpn
    echo "</key>" >>~/$1.ovpn
    echo "<tls-auth>" >>~/$1.ovpn
    cat /etc/openvpn/ta.key >>~/$1.ovpn
    echo "</tls-auth>" >>~/$1.ovpn
}

# Function to generate OVPN file
fun_geraovpn() {
    [[ "$respost" = @(s|S) ]] && {
        cd /etc/openvpn/easy-rsa/
        ./easyrsa build-client-full "$username" nopass
        newclient "$username"
        sed -e "s;auth-user-pass;<auth-user-pass>\n$username\n$password\n</auth-user-pass>;g" /root/$username.ovpn >/root/tmp.ovpn && mv -f /root/tmp.ovpn /root/$username.ovpn
    } || {
        cd /etc/openvpn/easy-rsa/
        ./easyrsa build-client-full "$username" nopass
        newclient "$username"
    }
} >/dev/null 2>&1

# Host configuration for OVPN
[[ -e /etc/openvpn/server.conf ]] && {
    _Port=$(grep -w 'port' /etc/openvpn/server.conf | awk '{print $2}')
    hst=$(sed -n '8 p' /etc/openvpn/client-common.txt | awk '{print $4}')
    rmt=$(sed -n '7 p' /etc/openvpn/client-common.txt)
    hedr=$(sed -n '8 p' /etc/openvpn/client-common.txt)
    prxy=$(sed -n '9 p' /etc/openvpn/client-common.txt)
    rmt2='/SSHPLUS?'
    rmt3='www.vivo.com.br 8088'
    prx='200.142.130.104'
    payload1='#payload "HTTP/1.0 [crlf]Host: m.youtube.com[crlf]CONNECT HTTP/1.0[crlf][crlf]|[crlf]"'
    payload2='#payload "CONNECT 127.0.0.1:1194[split][crlf] HTTP/1.0 [crlf][crlf]#"'
    vivo1="portalrecarga.vivo.com.br/recarga"
    vivo2="portalrecarga.vivo.com.br/controle/"
    vivo3="navegue.vivo.com.br/pre/"
    vivo4="navegue.vivo.com.br/controle/"
    vivo5="www.vivo.com.br"
    oi="d1n212ccp6ldpw.cloudfront.net"
    bypass="net_gateway"
    cert01="/etc/openvpn/client-common.txt"
    if [[ "$hst" == "$vivo1" ]]; then
        Host="Vivo Recharge"
    elif [[ "$hst" == "$vivo2" ]]; then
        Host="Vivo Control Recharge"
    elif [[ "$hst" == "$vivo3" ]]; then
        Host="Vivo Navigate"
    elif [[ "$hst" == "$vivo4" ]]; then
        Host="Vivo Control Navigate"
    elif [[ "$hst" == "$IP:$_Port" ]]; then
        Host="Vivo MMS"
    elif [[ "$hst" == "$oi" ]]; then
        Host="Oi"
    elif [[ "$hst" == "$bypass" ]]; then
        Host="Bypass Mode"
    elif [[ "$hedr" == "$payload1" ]]; then
        Host="OPEN SOCKS"
    elif [[ "$hedr" == "$payload2" ]]; then
        Host="OPEN SQUID"
    else
        Host="Custom"
    fi
}

# Progress bar function
fun_bar() {
    comando[0]="$1"
    comando[1]="$2"
    (
        [[ -e $HOME/fim ]] && rm $HOME/fim
        ${comando[0]} >/dev/null 2>&1
        ${comando[1]} >/dev/null 2>&1
        touch $HOME/fim
    ) >/dev/null 2>&1 &
    tput civis
    echo -ne "\033[1;33mPLEASE WAIT \033[1;37m- \033[1;33m["
    while true; do
        for ((i = 0; i < 18; i++)); do
            echo -ne "\033[1;31m#"
            sleep 0.1s
        done
        [[ -e $HOME/fim ]] && rm $HOME/fim && break
        echo -e "\033[1;33m]"
        sleep 1s
        tput cuu1
        tput dl1
        echo -ne "\033[1;33mPLEASE WAIT \033[1;37m- \033[1;33m["
    done
    echo -e "\033[1;33m]\033[1;37m -\033[1;32m OK !\033[1;37m"
    tput cnorm
}

# Function to edit OVPN host
fun_edithost() {
    clear
    echo -e "\E[44;1;37m          CHANGE OVPN HOST            \E[0m"
    echo ""
    echo -e "\033[1;33mCURRENT HOST\033[1;37m: \033[1;32m$Host"
    echo ""
    echo -e "\033[1;31m[\033[1;36m1\033[1;31m] \033[1;33mVIVO RECHARGE"
    echo -e "\033[1;31m[\033[1;36m2\033[1;31m] \033[1;33mVIVO NAVIGATE PRE"
    echo -e "\033[1;31m[\033[1;36m3\033[1;31m] \033[1;33mOPEN SOCKS \033[1;31m[\033[1;32mMODDED APP\033[1;31m]"
    echo -e "\033[1;31m[\033[1;36m4\033[1;31m] \033[1;33mOPEN SQUID \033[1;31m[\033[1;32mMODDED APP\033[1;31m]"
    echo -e "\033[1;31m[\033[1;36m5\033[1;31m] \033[1;33mVIVO MMS \033[1;31m[\033[1;37mAPN: \033[1;32mmms.vivo.com.br\033[1;31m]"
    echo -e "\033[1;31m[\033[1;36m6\033[1;31m] \033[1;33mBYPASS MODE \033[1;31m[\033[1;32mOPEN + INJECTOR\033[1;31m]"
    echo -e "\033[1;31m[\033[1;36m7\033[1;31m] \033[1;33mALL HOSTS \033[1;31m[\033[1;32m1 OVPN FOR EACH\033[1;31m]"
    echo -e "\033[1;31m[\033[1;36m8\033[1;31m] \033[1;33mEDIT MANUALLY"
    echo -e "\033[1;31m[\033[1;36m0\033[1;31m] \033[1;33mRETURN"
    echo ""
    echo -ne "\033[1;32mWHICH HOST TO USE? \033[1;37m "
    read respo
    [[ -z "$respo" ]] && {
        echo -e "\n\033[1;31mInvalid option!\033[0m"
        sleep 2
        fun_edithost
    }
    if [[ "$respo" = '1' ]]; then
        echo -e "\n\033[1;32mCHANGING HOST!\033[0m\n"
        fun_althost() {
            sed -i "7,9"d $cert01
            sleep 1
            sed -i "7i\remote $rmt2 $_Port\nhttp-proxy-option CUSTOM-HEADER Host $vivo1\nhttp-proxy $IP 80" $cert01
        }
        fun_bar 'fun_althost'
        echo -e "\n\033[1;32mHOST CHANGED SUCCESSFULLY!\033[0m"
        fun_geraovpn
        sleep 1.5
    elif [[ "$respo" = '2' ]]; then
        echo -e "\n\033[1;32mCHANGING HOST!\033[0m\n"
        fun_althost2() {
            sed -i "7,9"d $cert01
            sleep 1
            sed -i "7i\remote $rmt2 $_Port\nhttp-proxy-option CUSTOM-HEADER Host $vivo3\nhttp-proxy $IP 80" $cert01
        }
        fun_bar 'fun_althost2'
        echo -e "\n\033[1;32mHOST CHANGED SUCCESSFULLY!\033[0m"
        fun_geraovpn
        sleep 1.5
    elif [[ "$respo" = '3' ]]; then
        echo -e "\n\033[1;32mCHANGING HOST!\033[0m\n"
        fun_althostpay1() {
            sed -i "7,9"d $cert01
            sleep 1
            sed -i "7i\remote $rmt2 $_Port\n$payload1\nhttp-proxy $IP 8080" $cert01
        }
        fun_bar 'fun_althostpay1'
        echo -e "\n\033[1;32mHOST CHANGED SUCCESSFULLY!\033[0m"
        fun_geraovpn
        sleep 1.5
    elif [[ "$respo" = '4' ]]; then
        echo -e "\n\033[1;32mCHANGING HOST!\033[0m\n"
        fun_althostpay2() {
            sed -i "7,9"d $cert01
            sleep 1
            sed -i "7i\remote $rmt2 $_Port\n$payload2\nhttp-proxy $IP 80" $cert01
        }
        fun_bar 'fun_althostpay2'
        echo -e "\n\033[1;32mHOST CHANGED SUCCESSFULLY!\033[0m"
        fun_geraovpn
        sleep 1.5
    elif [[ "$respo" = '5' ]]; then
        echo -e "\n\033[1;32mCHANGING HOST!\033[0m\n"
        fun_althost5() {
            sed -i "7,9"d $cert01
            sleep 1
            sed -i "7i\remote $rmt3\nhttp-proxy-option CUSTOM-HEADER Host $vivo3\nhttp-proxy $prx:$_Port" $cert01
        }
        fun_bar 'fun_althost5'
        echo -e "\n\033[1;32mHOST CHANGED SUCCESSFULLY!\033[0m"
        fun_geraovpn
        sleep 1.5
    elif [[ "$respo" = '6' ]]; then
        echo -e "\n\033[1;32mCHANGING HOST!\033[0m\n"
        fun_althost6() {
            sed -i "7,9"d $cert01
            sleep 1
            sed -i "7i\remote $IP $_Port\nroute $IP 255.255.255.255 net_gateway\nhttp-proxy 127.0.0.1 8989" $cert01
        }
        fun_bar 'fun_althost6'
        echo -e "\n\033[1;32mHOST CHANGED SUCCESSFULLY!\033[0m"
        fun_geraovpn
        sleep 1.5
    elif [[ "$respo" = '7' ]]; then
        [[ ! -e "$HOME/$username.ovpn" ]] && fun_geraovpn
        echo -e "\n\033[1;32mCHANGING HOST!\033[0m\n"
        fun_packhost() {
            [[ ! -d "$HOME/OVPN" ]] && mkdir $HOME/OVPN
            sed -i "7,9"d $HOME/$username.ovpn
            sleep 0.5
            sed -i "7i\remote $rmt2 $_Port\nhttp-proxy-option CUSTOM-HEADER Host $vivo1\nhttp-proxy $IP 80" $HOME/$username.ovpn
            cp $HOME/$username.ovpn /root/OVPN/$username-vivo1.ovpn
            sed -i "8"d $HOME/$username.ovpn
            sleep 0.5
            sed -i "8i\http-proxy-option CUSTOM-HEADER Host $vivo3" $HOME/$username.ovpn
            cp $HOME/$username.ovpn /root/OVPN/$username-vivo2.ovpn
            sed -i "7,9"d $HOME/$username.ovpn
            sleep 0.5
            sed -i "7i\remote $rmt3\nhttp-proxy-option CUSTOM-HEADER Host $IP:$_Port\nhttp-proxy $prx 80" $HOME/$username.ovpn
            cp $HOME/$username.ovpn /root/OVPN/$username-vivo3.ovpn
            sed -i "7,9"d $HOME/$username.ovpn
            sleep 0.5
            sed -i "7i\remote $IP $_Port\nroute $IP 255.255.255.255 net_gateway\nhttp-proxy 127.0.0.1 8989" $HOME/$username.ovpn
            cp $HOME/$username.ovpn /root/OVPN/$username-bypass.ovpn
            sed -i "7,9"d $HOME/$username.ovpn
            sleep 0.5
            sed -i "7i\remote $rmt2 $_Port\n$payload1\nhttp-proxy $IP 8080" $HOME/$username.ovpn
            cp $HOME/$username.ovpn /root/OVPN/$username-socks.ovpn
            sed -i "7,9"d $HOME/$username.ovpn
            sleep 0.5
            sed -i "7i\remote $rmt2 $_Port\n$payload2\nhttp-proxy $IP 80" $HOME/$username.ovpn
            cp $HOME/$username.ovpn /root/OVPN/$username-squid.ovpn
            cd $HOME/OVPN && zip $username.zip *.ovpn >/dev/null 2>&1 && cp $username.zip $HOME/$username.zip
            cd $HOME && rm -rf /root/OVPN >/dev/null 2>&1
        }
        fun_bar 'fun_packhost'
        echo -e "\n\033[1;32mHOST CHANGED SUCCESSFULLY!\033[0m"
        sleep 1.5
    elif [[ "$respo" = '8' ]]; then
        echo ""
        echo -e "\033[1;32mEDITING OVPN FILE!\033[0m"
        echo ""
        echo -e "\033[1;31mATTENTION!\033[0m"
        echo -e "\033[1;33mTO SAVE, USE \033[1;32mCtrl + X, then Y\033[0m"
        sleep 4
        clear
        nano /etc/openvpn/client-common.txt
        echo ""
        echo -e "\033[1;32mEDITED SUCCESSFULLY!\033[0m"
        fun_geraovpn
        sleep 1.5
    elif [[ "$respo" = '0' ]]; then
        echo ""
        echo -e "\033[1;31mReturning...\033[0m"
        sleep 2
    else
        echo ""
        echo -e "\033[1;31mInvalid option!\033[0m"
        sleep 2
        fun_edithost
    fi
}

# Function to create SSH token
fun_usertoken() {
    clear
    tput setaf 7
    tput setab 4
    tput bold
    printf '%30s%s%-15s\n' "Create SSH Token"
    tput sgr0
    echo ""
    echo -ne "\033[1;32mEnter Token Name: \033[1;37m "
    read username
    [[ -z $username ]] && {
        echo -e "\n${cor1}Token name cannot be empty!${scor}\n"
        sleep 2
        return
    }
    [[ "$(grep -wc $username /etc/passwd)" != '0' ]] && {
        echo -e "\n${cor1}This token already exists. Try another name!${scor}\n"
        sleep 2
        return
    }
    [[ ${username} != ?(+|-)+([a-zA-Z0-9]) ]] && {
        echo -e "\n${cor1}Invalid token name! Use only letters and numbers!${scor}\n"
        sleep 2
        return
    }
    sizemin=$(echo ${#username})
    [[ $sizemin -lt 2 ]] && {
        echo -e "\n${cor1}Token name too short! Use at least 2 characters!${scor}\n"
        sleep 2
        return
    }
    echo -ne "\033[1;32mDays to expire: \033[1;37m "
    read dias
    [[ -z $dias ]] && {
        echo -e "\n${cor1}Number of days cannot be empty!${scor}\n"
        sleep 2
        return
    }
    [[ ${dias} != ?(+|-)+([0-9]) ]] && {
        echo -e "\n${cor1}Invalid number of days!${scor}\n"
        sleep 2
        return
    }
    [[ $dias -lt 1 ]] && {
        echo -e "\n${cor1}Number of days must be greater than zero!${scor}\n"
        sleep 2
        return
    }
    echo -ne "\033[1;32mConnection limit: \033[1;37m "
    read sshlimiter
    [[ -z $sshlimiter ]] && {
        echo -e "\n${cor1}Connection limit cannot be empty!${scor}\n"
        sleep 2
        return
    }
    [[ ${sshlimiter} != ?(+|-)+([0-9]) ]] && {
        echo -e "\n${cor1}Invalid connection limit!${scor}\n"
        sleep 2
        return
    }
    [[ $sshlimiter -lt 1 ]] && {
        echo -e "\n${cor1}Connection limit must be greater than zero!${scor}\n"
        sleep 2
        return
    }
    password=$(cat /etc/SSHPlus/Token.txt)
    final=$(date "+%Y-%m-%d" -d "+$dias days")
    gui=$(date "+%d/%m/%Y" -d "+$dias days")
    pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
    useradd -e $final -M -s /bin/false -p $pass $username >/dev/null 2>&1 &
    echo "$password" >/etc/SSHPlus/senha/$username
    echo "$username $sshlimiter" >>/root/usuarios.db
    # Send token to server
    curl -X POST "http://your-custom-server.com/pphdev/tokens" -d "{\"Name\":\"$username\",\"Key\":\"$username\",\"Valid\":\"$dias\",\"Expiration\":\"$final\"}" >/dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        echo -e "\n\033[1;32mToken created and synced with server!\033[0m"
    else
        echo -e "\n\033[1;31mFailed to sync token with server!\033[0m"
    fi
    clear
    echo -e "\E[44;1;37m       SSH ACCOUNT CREATED!      \E[0m"
    echo -e "\n\033[1;32mIP: \033[1;37m$IP"
    echo -e "\033[1;32mToken: \033[1;37m$username"
    echo -e "\033[1;32mExpires on: \033[1;37m$gui"
    echo -e "\033[1;32mConnection limit: \033[1;37m$sshlimiter"
}

# Function to rename token
fun_rename_token() {
    clear
    tput setaf 7
    tput setab 4
    tput bold
    printf '%30s%s%-15s\n' "Rename SSH Token"
    tput sgr0
    echo ""
    echo -ne "\033[1;32mCurrent Token Name: \033[1;37m "
    read old_username
    [[ -z $old_username ]] && {
        echo -e "\n${cor1}Token name cannot be empty!${scor}\n"
        sleep 2
        return
    }
    [[ "$(grep -wc $old_username /etc/passwd)" == '0' ]] && {
        echo -e "\n${cor1}This token does not exist!${scor}\n"
        sleep 2
        return
    }
    echo -ne "\033[1;32mNew Token Name: \033[1;37m "
    read new_username
    [[ -z $new_username ]] && {
        echo -e "\n${cor1}New token name cannot be empty!${scor}\n"
        sleep 2
        return
    }
    [[ "$(grep -wc $new_username /etc/passwd)" != '0' ]] && {
        echo -e "\n${cor1}This new token name already exists!${scor}\n"
        sleep 2
        return
    }
    [[ ${new_username} != ?(+|-)+([a-zA-Z0-9]) ]] && {
        echo -e "\n${cor1}Invalid new token name! Use only letters and numbers!${scor}\n"
        sleep 2
        return
    }
    # Update local files
    sed -i "s/^$old_username:/$new_username:/" /etc/passwd
    sed -i "s/^$old_username /$new_username /" /root/usuarios.db
    mv /etc/SSHPlus/senha/$old_username /etc/SSHPlus/senha/$new_username
    rm -f /root/$old_username.ovpn /root/$old_username.zip
    username=$new_username
    fun_geraovpn
    # Update server
    curl -X PUT "http://your-custom-server.com/pphdev/tokens/$old_username" -d "{\"Name\":\"$new_username\",\"Key\":\"$new_username\"}" >/dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        echo -e "\n\033[1;32mToken renamed to $new_username and synced with server!\033[0m"
    else
        echo -e "\n\033[1;31mFailed to sync renamed token with server!\033[0m"
    fi
    sleep 2
}

# Function to delete token
fun_delete_token() {
    clear
    tput setaf 7
    tput setab 4
    tput bold
    printf '%30s%s%-15s\n' "Delete SSH Token"
    tput sgr0
    echo ""
    echo -ne "\033[1;32mToken Name to Delete: \033[1;37m "
    read username
    [[ -z $username ]] && {
        echo -e "\n${cor1}Token name cannot be empty!${scor}\n"
        sleep 2
        return
    }
    [[ "$(grep -wc $username /etc/passwd)" == '0' ]] && {
        echo -e "\n${cor1}This token does not exist!${scor}\n"
        sleep 2
        return
    }
    echo -ne "\033[1;32mConfirm deletion? [y/n]: \033[1;37m "
    read confirm
    [[ "$confirm" != @(y|Y) ]] && {
        echo -e "\n\033[1;31mDeletion cancelled!${scor}\n"
        sleep 2
        return
    }
    # Delete from server
    curl -X DELETE "http://your-custom-server.com/pphdev/tokens/$username" >/dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        # Delete local files
        userdel -r $username >/dev/null 2>&1
        sed -i "/^$username /d" /root/usuarios.db
        rm -f /etc/SSHPlus/senha/$username
        rm -f /root/$username.ovpn /root/$username.zip
        echo -e "\n\033[1;32mToken $username deleted successfully!\033[0m"
    else
        echo -e "\n\033[1;31mFailed to delete token from server!\033[0m"
    fi
    sleep 2
}

# Main menu
fun_main_menu() {
    clear
    tput setaf 7
    tput setab 4
    tput bold
    printf '%30s%s%-15s\n' "SSH Account Management"
    tput sgr0
    echo ""
    echo -e "\033[1;31m[\033[1;36m1\033[1;31m] \033[1;33mCreate Token"
    echo -e "\033[1;31m[\033[1;36m2\033[1;31m] \033[1;33mRename Token"
    echo -e "\033[1;31m[\033[1;36m3\033[1;31m] \033[1;33mDelete Token"
    echo -e "\033[1;31m[\033[1;36m4\033[1;31m] \033[1;33mChange Host"
    echo -e "\033[1;31m[\033[1;36m0\033[1;31m] \033[1;33mExit"
    echo ""
    echo -ne "\033[1;32mWhat do you want to do? \033[1;37m "
    read option
    case $option in
        1) fun_usertoken ;;
        2) fun_rename_token ;;
        3) fun_delete_token ;;
        4) fun_edithost ;;
        0) exit 0 ;;
        *) echo -e "\n\033[1;31mInvalid option!\033[0m"; sleep 2; fun_main_menu ;;
    esac
}

# Check if required directory exists
[[ ! -e /usr/lib/sshplus ]] && {
    echo -e "\n${cor1}Required directory /usr/lib/sshplus not found!${scor}\n"
    exit 1
}

# Start the main menu
fun_main_menu
