#!/bin/bash

declare -a INT

if ping -c 1 -W 1 192.168.2.1 &>/dev/null
then
    echo 'Ok 123'
else
    echo 'fail 456'
fi

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

