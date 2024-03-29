#!/bin/bash

# Environment variables:
#   PINGD_INT - internal ( through tunnel) host
#   PINGD_EXT - external (internet) host
#   PINGD_TIMEOUT - ping's timeout (-W option's value')
#   PINGD_ITERATIONS - max loops in the 'check' state
#   PINGD_DELAY_LONG - sleep time in the up/down mode ~300 sec
#   PINGD_DELAY_SHORT - sleep time in the 'check' mode ~1 sec
#   PINGD_VERBOSE - show messages

state="up"
pingCount=0
pingInt=0
pingExt=0

(( ${PINGD_VERBOSE} )) && echo "pingd daemon started"

while (true); do

    [ 'x'${state} = 'xup' ]   && up=true || up=false
    [ 'x'${state} = 'xdown' ] && dn=true || dn=false
    [ 'x'${state} = 'xchk' ]  && chk=true || chk=false

    if ( ${up} )
    then sleep ${PINGD_DELAY_LONG}
    else sleep ${PINGD_DELAY_SHORT}
	fi

    if ( ${up} || ${chk} )
    then
        ping -c 1 -W ${PINGD_TIMEOUT} ${PINGD_INT} &>/dev/null && (( ++pingInt )) || (( --pingInt ))

    fi

    if ( ${dn} || ${chk} )
    then

        ping -c 1 -W ${PINGD_TIMEOUT} ${PINGD_EXT} &>/dev/null && (( ++pingExt )) || (( --pingExt ))

    fi

    (( pingInt > 0 )) && intUp=true || intUp=false
    (( pingExt > 0 )) && extUp=true || extUp=false


	(( ${PINGD_VERBOSE} )) && echo $(( pingCount+1 )) ${state} ${pingInt} ${pingExt} ${intUp} ${extUp}

    if (( ++pingCount < ${PINGD_ITERATIONS} ))
    then
        if ( ${chk} ); then continue; fi
    fi

    if ( ${up} )
    then
        if ( ! ${intUp} )
        then state='chk'
        fi
    elif ( ${dn} ); then
        if ( ${extUp} )
        then state='chk'
        fi
    else
        if ( ${intUp} )
        then
            state='up'
        elif ( ${extUp} )
        then
            (( ${PINGD_VERBOSE} )) && echo 'Tunnel restart required'
            systemctl restart strongswan
            sleep 10
        else
            state='down'
        fi
    fi

    pingCount=0
    pingInt=0
    pingExt=0

done

