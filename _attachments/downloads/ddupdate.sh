#!/bin/sh

#############################################
## BEGIN OF HEADER                         ##
## EDIT TO MAKE APPROPRIATE CONFIGURATIONS ##
#############################################
						
# Parameters left blank are not sent to dyndns.org
# All parameters except 'host', 'user' and 'pw' are optional.
# See https://www.dyndns.org/developers/specs/syntax.html for details.

user=test
pw="test"	# Here quotation marks should be used for the case that
		# the password contains special characters.
		# Attention: There are some special characters it cannot
		# successfully be updated with!

system=dyndns	# Without modification of this script
		# only dyndns is supported!

host=test.dnsalias.net
wildcard=OFF
mx=
backmx=
offline=

# Set https to 1 to enable SSL encryption of the data transfer.
# To disable encryption set https to 0.
# Note: Your "wget" program must support HTTPS (SSL data encryption),
# otherwise it won't work. You can easily check if your wget supports
# SSL-encryption by entering e.g. "wget https://www.dyndns.org".
# The newest version of wget is available at: ftp.gnu.org/pub/gnu/wget.
https=1

# If the ip address could not be detected (e.g. because there is no internet
# connection), ddupdate.sh will retry after this number of seconds:
no_ip_pause=10

# If the dyndns server is not available, ddupdate.sh can retry as often as
# it is specified here. If the server is still unavailable after then,
# ddupdate.sh waits as long as specified in "ip_check_pause".
retries=3

# ddupdate.sh will periodically check the ip address to determine if it has
# changed. Specify here the number of seconds that should lie between
# two ip checks.
# Note: This number should not be less than 600 (10 minutes).
# Webbased ip detection should not be used too extensive because traffic
# resources of dyndns.com have to be conserved.
# see: https://www.dyndns.com/support/kb/archives/dynamic_dns_and_nat.html
ip_check_pause=600	# 10 minutes

# Specify here the file ddupdate.sh can write the current ip address into.
# This might actually only be important on some flash memory devices
# (like routers many routers) because too much write cycles would harm the
# flash memory there. On such a devices you would better use a
# RAM-partition (e.g. /tmp/ip.tmp).
ip_file=ip.tmp


#################################
## END OF CONFIGURATION HEADER ##
#################################

detect_ip ()
{
  curr_ip=
  while [ -z "$curr_ip" ]
  do
    curr_ip=$(expr "$(wget -qO $ip_file  checkip.dyndns.com; cat $ip_file)"  : '.*[^0-9]\([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\)')
    if [ -n "$curr_ip" ]; then
        break
    else
        echo cannot detect ip address, retrying...
    fi
    sleep $1
  done
}


detect_ip $no_ip_pause

while :
do
  echo Got new ip address: $curr_ip

  ip=$curr_ip	# update ip address

  i=0

  while [ "$i" -le "$retries" ]	# for the case that the update server
				# is not available it will try again until
				# i equals retries
  do
    if [ $https -eq 0 ]; then
  	ret="$(wget -qO - "http://$user:"$pw"@members.dyndns.org/nic/update?system=$system&hostname=$host&myip=$ip&wildcard=$wildcard&mx=$mx&backmx=$backmx&offline=$offline")"
    else
	ret="$(wget --no-check-certificate -qO - "https://$user:"$pw"@members.dyndns.org/nic/update?system=$system&hostname=$host&myip=$ip&wildcard=$wildcard&mx=$mx&backmx=$backmx&offline=$offline")"
    fi

    if [ -n "$(expr "$ret" : '\(good\)')" ]; then
  	echo The update of $host was successful!
	break
    elif [ -n "$(expr "$ret" : '\(nochg\)')" ]; then
  	echo No ip address update necessary, no change in ip address! 
	break
    elif [ -n "$(expr "$ret" : '\(badsys\)')" ]; then
  	echo The \"system\" parameter given is not valid!
	break
    elif [ -n "$(expr "$ret" : '\(badagent\)')" ]; then
  	echo The user agent that was sent has been blocked.
	break
    elif [ -n "$(expr "$ret" : '\(badauth\)')" ]; then
  	echo The username and password pair do not match a real user!
	break
    elif [ -n "$(expr "$ret" : '\(!donator\)')" ]; then
  	echo An option available only to credited users \(such as offline URL\)
  	echo  was specified, but the user is not a credited user!
	break
    elif [ -n "$(expr "$ret" : '\(notfqdn\)')" ]; then
  	echo The hostname specified is not a fully-qualified domain name!
	break
    elif [ -n "$(expr "$ret" : '\(nohost\)')" ]; then
  	echo The hostname specified does not exist \(or is not in the
  	echo service specified in the system parameter\)
	break
    elif [ -n "$(expr "$ret" : '\(!yours\)')" ]; then
  	echo The hostname specified exists, but not under the username specified.
	break
    elif [ -n "$(expr "$ret" : '\(numhost\)')" ]; then
  	echo Too many or no hosts specified in an update.
	break
    elif [ -n "$(expr "$ret" : '\(abuse\)')" ]; then
  	echo The hostname specified is blocked for update abuse.
	break
    elif [ -n "$(expr "$ret" : '\(dnserr\)')" ]; then
  	echo Server error: DNS error encountered.
	break
    elif [ -n "$(expr "$ret" : '\(911\)')" ]; then
  	echo There is a serious problem on server side
  	echo \(e.g. such as a database or DNS server failure\).
	break
    elif [ -n "$ret" ]; then
	echo Unknown return code: $ret
	break
    elif [ -z "$ret" ]; then
	echo no connection to the update server, retrying...
	i=$(expr $i + 1)
	sleep $no_ip_pause
    fi
  done

  while [ "$ip" = "$curr_ip" ] 
  do
    sleep $ip_check_pause
    detect_ip $no_ip_pause
  done

done
