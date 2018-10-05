#!/usr/bin/env bash

# debug calls
shared_debug=${shared_debug:-0}

shared_execute_sh_loaded=${shared_execute_sh_loaded:-0}
if [ "x0" != "x${shared_execute_sh_loaded}" ]; then
  if [ "x1" == "x${shared_debug}" ]; then
    echo "--> execute.sh already included"
  fi
else
  shared_execute_sh_loaded=1
  shared_exec_err_ocurred=${shared_exec_err_ocurred:-0}

  pkg::import logger
  pkg::import exiting

  function execute::check_and_error {
    local result=${1:-1}
    local message=${2:-"wrong call; defaulting to error"}
    if [ ${result} -ne 0 ]; then
      shared_exec_err_ocurred=${result}
      logger::error "Step failed (${message}). See log"
    fi
  }

  function execute::exec_and_continue_on_ok() {
    local call=${1:-"/bin/false"}
    logger::log "Executing [${call}] in [$(pwd)]"
    eval "${call}"
    local result=$?
    exiting::check_and_exit $result ${call}
  }

  function execute::no_exit_immediately {
    local call=${1:-"/bin/false"}
    logger::log "Executing [${call}] in [$(pwd)]"
    set +e
    eval "${call}"
    set -e
  }

fi