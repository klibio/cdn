#!/bin/bash
# activate bash checks for unset vars, pipe fails
set -eauo pipefail
# locate script folder and set working directory
SCRIPT_DIR="$( cd $( dirname ${BASH_SOURCE[0]} ) >/dev/null 2>&1 && pwd )" \
  && cd ${SCRIPT_DIR}/..

NC='\033[0m' # no color
BLUE='\033[0;34m';
RED='\e[31m';
GREEN='\e[42m';
headline() {
  if [ -t 1 ]; then # identify if stdout is terminal
    echo -ne "${BLUE}#\n# $1\n#\n${NC}"
  else
    echo -ne "#\n# $1\n#\n"
  fi
}
padout() {
  if [ -t 1 ]; then # identify if stdout is terminal
    printf -v x '%-60s' "$1"; echo -ne "${BLUE}$(date +%H:%M:%S) $x${NC}"
  else
    printf -v x '%-60s' "$1"; echo -ne "$(date +%H:%M:%S) $x"
  fi
}
err() {
  if [ -t 1 ]; then # identify if stdout is terminal
    echo -e " - ${RED}FAILED${NC}"
  else
    echo -e " - FAILED"
  fi
}
succ() {
  if [ -t 1 ]; then # identify if stdout is terminal
    echo -e " - ${GREEN}SUCCESS${NC}"
  else
    echo -e " - SUCCESS"
  fi
}

headline "existing environment"
env | sort

_BRANCH=${BUILD_SOURCEBRANCH:=$(git rev-parse --abbrev-ref HEAD)}

# local environment configuration
         _DATE=$(date +'%Y.%m.%d-%H.%M.%S')
      _VCS_REF=$(git rev-list -1 HEAD)
_VCS_REF_SHORT=$(git describe --dirty --always)
      _VERSION=$(cat ${SCRIPT_DIR}/version.txt)
          _TAG=${_VERSION}.${_DATE}-${_VCS_REF_SHORT}
         major=$(echo ${_VERSION} | sed -E "s/(.*)\.(.*)\.(.*)/\1/g")
         minor=$(echo ${_VERSION} | sed -E "s/(.*)\.(.*)\.(.*)/\2/g")
        bugfix=$(echo ${_VERSION} | sed -E "s/(.*)\.(.*)\.(.*)/\3/g")

envCompleted=true
