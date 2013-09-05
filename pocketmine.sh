#!/bin/bash

PHP='./bin/php'
PHP_OPTS='-d enable_dl=On'
PMMP='PocketMine-MP.php'
WORLD_WORLD='world'
WORLDS="$WORLD_WORLD"
MAP_DIR='worlds'
LOG_DIR='log'
LOG_FILE='console.log'
EVIL_KEY='C-c'
MAX_TRY='600'
SESSION='PocketMine'
PREFIX='C-a'
CMDS_BEFORE_STOP=''

#= functions ==================================================================
check_has_tmux(){
    if [[ -z $(which tmux) ]]; then
        "Install the tmux first!!"
        exit 0
    fi
}

check_if_in_tmux(){
    if [[ "$TERM" == 'screen' ]] || [[ -n $TMUX ]]; then
        echo "Can't Create/Attach session in other tmux session!"
        exit 1
    fi
}

check_result(){
    if [[ "$?" == 0 ]]; then
        echo "$1: Done."
    else
        echo "$1: Fail!"
        exit 1
    fi
}

check_fail(){
    if [[ "$?" != 0 ]]; then
        echo 'Fail!'
        exit 1
    fi
}

bind_key(){
    tmux set-option -t $SESSION prefix $PREFIX >/dev/null 2>&1
    #. map Ctrl+c to prefix-key/detach to prevent PocketMine server from killing. 
    tmux set-option -t $SESSION prefix2 $EVIL_KEY >/dev/null 2>&1
    tmux bind $EVIL_KEY detach
}

unbind_key(){
    tmux unbind $EVIL_KEY 2>/dev/null
}

start_server(){
    tmux new-session -d -s $SESSION
    tmux new-window -t "$SESSION":1 -n Console \
        "$PHP $PHP_OPTS $PMMP"
    check_result 'Start'
    tmux kill-window -t "$SESSION":0  
    bind_key
}

attach_console(){
    check_if_in_tmux
    tmux attach-session -t "$SESSION" #\; set-option -g prefix $PREFIX
}

detach_clients(){
    tmux detach -s "$SESSION" 2>/dev/null
}

send_command(){
    tmux send -t $SESSION "$1" ENTER 2>/dev/null
}

send_ctrl_key(){
    tmux send -t $SESSION "$1" 2>/dev/null
}

clean_cmd_line(){
    send_ctrl_key 'C-e' #. move to end of line (END)
    for (( i = 0; i < 50; i++ )); do
        send_ctrl_key 'C-h' #. clean the command line (BACKSPACE)
    done
}

session_exist(){
    #. print message if not exist
    tmux has-session -t $SESSION 2>&1
}

stop_server(){
    echo 'Please wait ...'
    detach_clients
    unbind_key
    clean_cmd_line
    try=0
    #. save data
    send_command "save-all"
    while [[ -z $(session_exist) ]]; do
        #. send custom commands
        #. TODO: handle the args.
        if [[ ! -z "$CMDS_BEFORE_STOP" ]]; then
            for cmd in CMDS_BEFORE_STOP; do
                send_command "$cmd"
            done
        fi
        #. stop the server
        send_command "stop"
        sleep 1
        try=$(($try+1))
        if [[ "$try" -ge "$MAX_TRY" ]]; then
            echo "Stop: Fail."
            exit 1
        fi
    done
    echo 'Stop: Done.'
}

kill_server(){
    detach_clients
    unbind_key
    clean_cmd_line
    tmux kill-session -t "$SESSION" 2>/dev/null
    check_result 'Stop'
}

purge_maps(){
    rm -rf $MAP_DIR 2>/dev/null
}

rename_maps(){
    for dir in "$WORLDS"; do
        mv $MAP_DIR/$dir $MAP_DIR/$dir.$(date +"%s") 2>/dev/null
    done
}

start_server_if_need(){
    if [[ -z $(session_exist) ]]; then
        echo "session exist: $SESSION"
    else
        start_server
    fi
}

today(){
     date +"%Y%m%d_%s"
}

log_rotate(){
    log=$LOG_DIR/server.$(today).log
    mkdir -p $LOG_DIR
    cat $LOG_FILE > $log
    echo "Log rotate to $log!" > $LOG_FILE
}

confirm(){
    read -p "Are you sure? (yes/no): " answer
    case $answer in
        yes)
            foo=bar
            ;;
        *)
            echo 'Abort.'
            exit 0
            ;;
    esac
}

strip_color(){
    cat -v $1 | sed -e 's#\^\[\[\([0-9]*;*\)*m##g'
}

usage(){
    echo -e "Usage: $(basename $0) [CMD]\n"
    echo -e "Available CMDs:"
    echo -e "  start\t\t\tStart PocketMine server."
    echo -e "  attach\t\tAttach PocketMine server console."
    echo -e "  console\t\tAlias for attach."
    echo -e "  stop\t\t\tStop PocketMine server. (graceful)"
    echo -e "  restart\t\tRestart PocketMine server. (graceful)"
    echo -e "  kill\t\t\tKill the PocketMine server."
    echo -e "  cmd \"MY COMMAND\"\tSend command to PocketMine server."
    echo -e "  plainlog \"LOGFILE\"\tStrip color code from log file."
    echo -e "  log-rotate\t\tLog rotate."
    echo -e "  remake-world\t\tRegenerate worlds and keep old worlds. (need restart)"
    echo -e "  purge-world\t\tRegenerate worlds. (need restart)"
}

#= main program ===============================================================
cd $(dirname $0)
check_has_tmux
case $1 in
    start)
        start_server_if_need
        ;;
    attach|console)
        attach_console
        ;;
    stop)
        stop_server
        ;;
    restart)
        stop_server
        start_server
        ;;
    kill)
        kill_server
        ;;
    cmd)
        detach_clients
        clean_cmd_line
        send_command "$2"
        ;;
    log-rotate)
        log_rotate
        ;;
    remake-world)
        confirm
        stop_server
        rename_maps
        start_server
        ;;
    purge-world)
        confirm
        stop_server
        purge_maps
        start_server
        ;;
    plainlog)
        strip_color "$2"
        ;;
    *)
        usage
        ;;
esac

