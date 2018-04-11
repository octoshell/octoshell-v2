#HOST="-p 2222 -c 3des -o StrictHostKeyChecking=no cli"
HOME_BASE='/home/'

LOG_FILE="/tmp/octo.log"

op="echo"
op=""

function log(){
  echo "$@" >>$LOG_FILE
}

