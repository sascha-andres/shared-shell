#!/usr/bin/env bash

# debug calls
shared_debug=${shared_debug:-0}

shared_exiting_sh_loaded=${shared_exiting_sh_loaded:-0}
if [ "x0" != "x${shared_exiting_sh_loaded}" ]; then
  if [ "x1" == "x${shared_debug}" ]; then
    echo "--> exiting.sh already included"
  fi
else
  shared_exiting_sh_loaded=1
  
  shared_exec_err_ocurred=${shared_exec_err_ocurred:-0}

  pkg::import logger

  function exiting::quit() {
    local result=${1:-0}
    logger::write
    logger::log "Exiting with result ${result}"
    exit "${result}"
  }

  function exiting::signalled_exit {
    if [ "${shared_exec_err_ocurred}" -ne 1 ]; then
      exiting::quit "${shared_exec_err_ocurred}"
    fi
    exit 0
  }

  function exiting::check_and_exit {
    local result=${1:-1}
    local message=${2:-"wrong call; defaulting to exit"}
    if [ "${result}" - 0 ]; then
      logger::error "Step failed (${message}). See log"
      exiting::quit "${result}"
    fi
  }
fi