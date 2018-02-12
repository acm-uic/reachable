#!/usr/bin/env bash

# reachable.sh
# Author: clee231
# Editor(s): mac@acm.cs.uic.edu
# ACM@UIC SIGSysAdmin 2018


##############################################################################
# DO NOT modify this file, unless you are modifying the functionality.
# Configuration to this script daemon should be made in the hidden .env file.
##############################################################################

source .env

#previousStatus 3 states init|down|up
previousStatus="init"

#Colors as hex values
green="#36a64f"
red="#d50200"

# All parameters are required. $channel, $status, $reportNode
json_output () {
[[ $2 == 1 ]] && color=$green || color=$red
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
    pingResponse=$(ping -c 1 "$HOSTNAME")
    if [ "$?" == 0 ]
    then
        echo "[$(date)] Ping Online for $HOSTNAME"
        payloadResponse=$(json_output "$CHANNEL" 1 "$NODENAME")
        if [ $previousStatus != "up" ]
        then
            previousStatus="up"
            curl --data "${payloadResponse}" -H "Content-Type: $CONTENTTYPE" -H "Authorization: Bearer $KEY" -X POST "$POSTURL"
        fi
    else
        echo "[$(date)] Ping Offline for $HOSTNAME"
        if [ $previousStatus != "down" ]
        then
            previousStatus="down"
            payloadResponse=$(json_output "$CHANNEL" 0 "$NODENAME")
            curl --data "${payloadResponse}" -H "Content-Type: $CONTENTTYPE" -H "Authorization: Bearer $KEY" -X POST "$POSTURL"
        fi
    fi
    if [ $previousStatus == "up" ]
    then
        sleep 60
    else
        sleep 10
    fi
done
