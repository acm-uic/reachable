#!/usr/bin/env bash

# reachable.sh
# Author: clee231
# ACM@UIC SIGSysAdmin 2018


##############################################################################
# DO NOT modify this file, unless you are modifying the functionality.
# Configuration to this script daemon should be made in the hidden .env file.
##############################################################################

source .env

prevstatus=-1

# All parameters are required. $channel, $status, $reportNode
json_output () {
[[ $2 == 1 ]] && color="#36a64f" || color="#d50200"
[[ $2 == 1 ]] && status="Up" || status="Down"
payload=$(cat <<EOF
{"channel":"$1",
 "as_user":true,
 "text":"The current time is: <!date^$(date +%s)^{date} at {time}|$(date)>",
 "attachments": [
    {
            "fallback": "$MSG_TITLE",
            "color": "$color",
            "author_name": "$DAEMON_NAME",
            "author_link": "$DAEMON_URL",
            "author_icon": "$DAEMON_ICON",
            "title": "$HOSTNAME",
            "text": "Disruption Event",
            "fields": [
                {
                    "title": "Priority",
                    "value": "Info",
                    "short": true
                },
                {
                    "title": "Status",
                    "value": "$status",
                    "short": true
                },
                {
                    "title": "Reporting Node",
                    "value": "$3",
                    "short": true
                },
            ],
            "footer": "$DAEMON_TITLE",
            "footer_icon": "$DAEMON_ICON",
            "ts": $(date +%s)
    }
 ]
}
EOF
)
 echo "$payload"
}


while true; do
    # shellcheck disable=SC2034
    pingres="$(ping -c 1 "$HOSTNAME")"
    if [ "$?" == 0 ]
    then
        echo "[$(date)] Ping Online for $HOSTNAME"
        payloadres="$(json_output "$CHANNEL" 1 "$NODENAME")"
        if [ $prevstatus != 1 ]
        then
            prevstatus=1
            curl --data "${payloadres}" -H "Content-Type: $CONTENTTYPE" -H "Authorization: Bearer $KEY" -X POST "$POSTURL"
        fi
    else
        echo "[$(date)] Ping Offline for $HOSTNAME"
        if [ $prevstatus != 0 ]
        then
            prevstatus=0
            payloadres=$(json_output "$CHANNEL" 0 "$NODENAME")
            curl --data "${payloadres}" -H "Content-Type: $CONTENTTYPE" -H "Authorization: Bearer $KEY" -X POST "$POSTURL"
        fi
    fi
    if [ $prevstatus == 1 ]
    then
        sleep 60
    else
        sleep 10
    fi
done
