#!/bin/bash



HOST1="192.168.0.1"
HOST2="forest.p-dok.ru"

DELAY1=2
TIMEOUT=1

declare -a rhost1
declare -a rhost2

rhost1=(0 0 0 0 0 0 0 0 0 0)
rhost2=(0 0 0 0 0 0 0 0 0 0)

ptr1=0
ptr2=0
ptr_max=3

state="up"
in1_state=""
in2_state=""

allow_check=false


while (true); do

	sleep ${DELAY1}

	(( ptr1 == ptr_max )) && allow_check=true
	(( ptr2 == ptr_max )) && allow_check=true

    if [ 'x'${state} = 'xup' ] ; then

        if ping -c 1 -W ${TIMEOUT} ${HOST1} &>/dev/null
        then
            rhost1[$ptr1]=1
        else
            rhost1[$ptr1]=-1
        fi
        (( ptr1++ ))
        (( ptr1>ptr_max )) && ptr1=0

    fi

    if [ 'x'${state} = 'xdown' ] ; then

        if ping -c 1 -W ${TIMEOUT} ${HOST2} &>/dev/null
        then
            rhost2[$ptr2]=1
        else
            rhost2[$ptr2]=-1
        fi

        (( ptr2++ ))
        (( ptr2>ptr_max )) && ptr2=0
    fi


    sum1=0
    for i in "${rhost1[@]}"; do
        (( sum1 += $i ))
    done
    sum2=0
    for i in "${rhost2[@]}"; do
        (( sum2 += $i ))
    done

    (( sum1 >= 0 )) && state="up" || state="down"

    if ${allow_check}
    then
        in1_state="check"
        (( sum1 > ptr_max )) && in1_state="up"
        (( sum1 < -ptr_max )) && in1_state="down"

        in2_state="check"
        (( sum2 > ptr_max )) && in2_state="up"
        (( sum2 < -ptr_max )) && in2_state="down"

        if [ 'x'${in1_state} = 'xdown' ] && [ 'x'${in2_state} = 'xup' ] ; then
            echo 'Restart required'
        fi

        if [ 'x'${in2_state} = 'xdown' ]; then
            echo '${HOST2} - unreacheble'
        fi
    fi

    echo ${ptr1} $sum1 ${rhost1[@]} $in1_state
    echo ${ptr2} $sum2 ${rhost2[@]} $in2_state


done


#############
# https://unix.stackexchange.com/questions/426862/proper-way-to-run-shell-script-as-a-daemon
# https://rtfm.co.ua/bash-ispolzovanie-komandy-trap-dlya-perexvata-signalov-preryvaniya-processa/
#####################

# #!/bin/bash

# declare -a STACK

# SP=0
# X=

# push()
# {
#     STACK[$SP]="$1"
#     (( SP++ ))
# }

# pop()
# {
#     (( SP-- ))
#     X="${STACK[$SP]}"
# }

# for S in "first" "second" "third"; do
#     push "$S"
# done

# while (( SP != 0 )); do
#     pop
#     echo "$X"
# done

#####################3
# #!/bin/bash

# declare -a QUEUE

# X=

# BEGIN=0
# END=0
# S_SIZE=100

# append_queue()
# {
#     QUEUE[$END]="$1"
#     (( END++ ))
#     if (( END >= S_SIZE )); then
#         END=0
#     fi
# }

# remove_queue()
# {
#     X="${QUEUE[$BEGIN]}"
#     (( BEGIN++ ))
#     if (( BEGIN >= S_SIZE )); then
#         BEGIN=0
#     fi
# }


# for S in "first" "second" "third"; do
#     append_queue "$S"
# done

# while (( BEGIN != END )); do
#     remove_queue
#     echo "$X"
# done

