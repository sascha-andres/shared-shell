# shell scripts to include

## History

|Version|Description|
|---|---|
|0.4.8|fix for unwanted fish output|
|0.4.6-1|fix for nfpm config|
|0.4.6|Fish Shell v3|
|0.4.3|add git functions|
|0.4.1|install location|
| |name config.sh module.sh and move to install location|
|0.4.0|no-exit-immediatly|
| |color support|
|0.3.0|Adopt packages|
|0.2.0|Added loader with __import and __module_loaded|
| |add fine grained bash option handling|
| |prepend __ to function names|
|0.1.0|Initial version|

## Configuration variables

|Variable|Since|Description|
|---|---|---|
|shared_logger_tag|0.1.0|If set write not only to stdout but to logger|
|||Defaults to empty string|
|shared_verbose|0.1.0|Toggle whether to be verbose on output.|
|||If sth else than 1 does only write warnings, errors or explicitly called writealways|
|||Defaults to 1|

## /etc/sascha-andres/shared-shell/config

__Include this file always__

This sets the install location and some configuration properties. Currently existing variables:

|Variable|Since|Description|
|---|---|---|
|shared_pipefail|0.2.0|Enable pipefail only when 1|
|||Defaulting to 1|
|shared_exit_immediatly|0.2.0|Exit immediatly when sub command fails|
|||Defaulting to 1|
|shared_install_location|0.1.0|The location where the scripts are located|
|||always use this variable to source other scripts|
|||Defaulting to `/opt/sascha-andres/shared-shell`|
|shared_debug|0.1.0|If set turns on debugging with `set -x`

Additionally, this sets `set -euo pipefail`

## Importing modules

You do not source modules directly but import them using `__import`. The loader prevents modules from being loaded multiple times.

Sample:

    pkg::import logger # will load logger functions

To check if a module is loaded you can do

    if [ $(pkg::module_loaded ${module}) == "n" ]; then
      echo not loaded
    fi

## Modules

### logger

Provides some helper methods to write output to console/logger. Prepend each function with `logger::`

To turn off colored output set shared_logger_colored=0

#### Methods

##### header

Print out a header to denote a section

Sample call:

    logger::header "header"
    
Will print

    <empty line>
    *** header ***
    <empty line>

##### write

Print out text

Sample call:

    logger::write "hello world"

Will print

	hello world

##### writealways

Same as write but prints out even if `shared_verbose=0`

##### warn

Write a warning to stdout. Use this to indicate a problem that allows to continue.

Sample call:

    logger::warn "warn"
    
Will print

	?? warn ??

##### error

Write an error to stderr. Use this this indicate a problem that result in stopping the execution.

Sample call:

    logger::error "error"
    
Will print

	!! error !!

##### log

Write a log message to stdout

Sample call:

    logger::log "log"

Will print

    --> log

### execute

#### Defined variables

Variable `shared_exec_err_ocurred` is used to have exit code for `check_and_error` and `signalled_exit` in sync. . Prepend each function with `executing::`

#### no-exit-immediatly

Wraps the command in +e/-e

#### check_and_error

Print out an error based on parameter 1, message passed as parameter 2.

Paramter 1 defaults to -1, error message to 'wrong call; defaulting to error'

#### exec_and_continue_on_ok

Executes the given parameter (one!) and evaluates the return code with `check_and_exit`

### exiting

Prepend each function with `exiting::`

#### signalled_exit

Exits if `check_and_error` was called with a non zero result code

#### check_and_exit

Exit the script based on parameter 1, message passed as parameter 2 printed out as error. Calls quit from exiting.sh

Paramter 1 defaults to -1, error message to 'wrong call; defaulting to error'

#### quit

Prints a log line with exit code and ends script execution
