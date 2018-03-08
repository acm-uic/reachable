#!/bin/bash
#the following are subdomains to ping and check if it's down
array=(
    "acm.cs.uic.edu"
    "macserve.cs.uic.edu"
    "linux.cs.uic.edu"
    "malware.cs.uic.edu"
    "hans.cs.uic.edu"
    "brink.cs.uic.edu"
    "sigbuild.cs.uic.edu"
    "dvorak.cs.uic.edu"
    "cuda.cs.uic.edu"
    "siggame.cs.uic.edu"
    "wics.cs.uic.edu"
    "littlebell.cs.uic.edu"
)
for subDomain in ${array[*]}
do
    _=$(ping -c 1  $subDomain)
    
    if [ $? -ne 0 ]
    then
	echo "failed on $subDomain"
    fi
done
