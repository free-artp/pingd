#!/bin/bash

declare -a INT

if ping -c 1 -W 1 &>/dev/null
then
    echo 'Ok 123'
else
    echo 'fail'
fi
