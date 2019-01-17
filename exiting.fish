#!/usr/bin/env fish

set -q shared_debug; or set -g shared_debug 0

set -q shared_exiting_sh_loaded; or set -g shared_exiting_sh_loaded 0

if test 1 -eq $shared_exiting_sh_loaded
  if test 1 -eq $shared_debug
    echo "--> exiting.sh already included"
  end
else
  set -g shared_exiting_sh_loaded 1
  
  set -q shared_exec_err_ocurred; or set -g shared_exec_err_ocurred 0

  pkg_import logger

  function exiting_quit --description "stop executing"
    logger_write
    logger_log "Exiting with result $argv"
    exit $argv
  end

  function exiting_signalled_exit --description "exit if error occurred"
    if test shared_exec_err_ocurred -ne 1
      exiting_quit $shared_exec_err_ocurred
    end
    exiting_quit 0
  end
 
  function exiting_check_and_exit --description "exit for result"
    if test 0 -ne $argv[1]
      logger_error "Step failed ($argv[2]). See log"
      exiting_quit $argv[1]
    end
  end

end