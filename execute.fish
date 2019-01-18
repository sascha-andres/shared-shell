#!/usr/bin/env bash

set -q shared_debug; or set -g shared_debug 0
set -q shared_execute_sh_loaded; or set -g shared_execute_sh_loaded 0

if test 0 -ne $shared_execute_sh_loaded
  if test 1 -eq $shared_debug
    echo "--> execute.sh already included"
  end
else
  set -g shared_execute_sh_loaded 1
  set -q shared_exec_err_ocurred; or set -g shared_exec_err_ocurred 0

  pkg_import logger
  pkg_import exiting

  function execute_check_and_error 
    if test $argv[0] -ne 0
      set -g shared_exec_err_ocurred $result
      logger_error "Step failed ($argv[1]). See log"
    end
  end

  function execute_exec_and_continue_on_ok
    set -l pwd (pwd)
    set -l params $argv
    logger_log "Executing [$params] in [$pwd]"
    eval "$params"
    exiting_check_and_exit $status "$params"
  end

end