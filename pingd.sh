#!/bin/bash

state="up"
pingCount=0
pingInt=0
pingExt=0


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


	echo `date +%H:%M:%S` $(( pingCount+1 )) ${pingInt} ${pingExt} ${intUp} ${extUp}

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
            echo 'Restart required'
            systemctl restart strongswan
            sleep 10
        else
            state='dn'
        fi
    fi

    pingCount=0
    pingInt=0
    pingExt=0

    echo '----------'${state}
done

