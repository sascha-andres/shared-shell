#! /usr/bin/env fish

set shared_install_location (pwd)
# shared_debug=0


if not test -e "$shared_install_location/module.fish"
  echo "!! config not found !!"
  exit 1
end

source "$shared_install_location/module.fish"

pkg_module_loaded "logger"

if [ $status -eq 0 ]
  echo "Logger is loaded: y"
else
  echo "Logger is loaded: n"
end

pkg_import logger
pkg_import exiting
pkg_import execute

logger_header "logger"

pkg_module_loaded "logger"
if [ $status -eq 0 ]
  logger_write "Logger is loaded: y"
else
  logger_write "Logger is loaded: n"
end

logger_log "log"
logger_warn "warn"
logger_error "error"
logger_writealways "writealways"

logger_header "execute"
execute_exec_and_continue_on_ok "echo 'a'"

logger_header "exiting"
exiting_quit 0

# pkg::import logger
# pkg::import execute
# pkg::import exiting
# pkg::import git
# 
# git_from=a69824f
# git_to=7a24809
# 
# logger::header "execute"
# execute::exec_and_continue_on_ok "echo 'a'"
# 
# logger::header "git"
# 
# rev="${git_from}"
# git::set_describe
# logger::writealways "result: ${git_result_describe}"
# 
# rev="0.4.1"
# git::set_describe_tags
# logger::writealways "result: ${git_result_describe_tags}"
# 
# newrev=${git_to}
# oldrev=${git_from}
# 
# git::set_rev_types
# logger::writealways "git_result_newrev_type: ${git_result_newrev_type}"
# logger::writealways "git_result_oldrev_type: ${git_result_oldrev_type}"
# logger::writealways "git_result_rev: ${git_result_rev}"
# logger::writealways "git_result_rev_type: ${git_result_rev_type}"
# 
# git::set_change_type
# logger::writealways "git_result_change_type: ${git_result_change_type}"
# 
# refname="develop"
# git::set_new_commits
# logger::writealways "git_result_new_commits: ${git_result_new_commits}"