#!/bin/bash
case "$1" in
  start)
    mkdir -p "$(dirname "$2")"
    nohup gpu-screen-recorder -w screen -a default_output -c mp4 -o "$2" &>/dev/null &
    echo $! > /tmp/qs_rec_pid
    echo "1" > /tmp/qs_rec_state
    ;;
  stop)
    if [[ -f /tmp/qs_rec_pid ]]; then
      pid=$(cat /tmp/qs_rec_pid)
      kill -SIGINT "$pid" 2>/dev/null
      rm -f /tmp/qs_rec_pid
    fi
    echo "0" > /tmp/qs_rec_state
    ;;
  state)
    cat /tmp/qs_rec_state 2>/dev/null || echo "0"
    ;;
  running)
    if [[ -f /tmp/qs_rec_pid ]]; then
      pid=$(cat /tmp/qs_rec_pid)
      kill -0 "$pid" 2>/dev/null && echo "1" || echo "0"
    else
      echo "0"
    fi
    ;;
  cleanup)
    rm -f /tmp/qs_rec_pid /tmp/qs_rec_state
    ;;
esac
