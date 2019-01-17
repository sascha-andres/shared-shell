#!/usr/bin/env fish

set -q shared_logger_sh_loaded; or set -g shared_logger_sh_loaded 0

if test 1 -eq $shared_logger_sh_loaded
  # if [ "x1" == "x${shared_debug}" ]; then
    echo "logger.sh already included"
  # fi
else
  set -g shared_logger_sh_loaded 1

  set -q shared_logger_tag; or set -g shared_logger_tag
  set -q shared_verbose; or set -g shared_verbose 1
  set -q shared_logger_colored; or set -g shared_logger_colored 1
  set -q shared_logger_echo_cmd; or set -g shared_logger_echo_cmd "/bin/echo -e"

  function logger_header -d "print header"
    logger_write
    logger_write (set_color cyan) "***" (set_color normal) $argv (set_color cyan) "***" (set_color normal)
    logger_write
  end

  function logger_write -d "write to stdout"
    if test -z $shared_logger_tag
      if test 1 -eq $shared_verbose > /dev/null
        echo "$argv"
      end
    else
      if test 1 -eq $shared_verbose > /dev/null
        echo $content
      end
      echo $content | logger -t "$shared_logger_tag"
    end
  end

  function logger_writealways -d "write to stdout even if verbose is 0"
    if test -z $shared_logger_tag
      echo "$argv"
    else
      echo "$argv"
      echo "$argv" | logger -t "$shared_logger_tag"
    end
  end

  function logger_warn -d "print a warning"
    logger_writealways (set_color yellow) "??" (set_color normal) $argv (set_color yellow) "??" (set_color normal)
  end

  function logger_error -d "print an error"
    logger_writealways (set_color red) "!!" (set_color normal) $argv (set_color red) "!!" (set_color normal) > /dev/stderr
  end

  function logger_log -d "log something"
    logger_write (set_color blue) "-->" (set_color normal) " " (set_color green) $argv (set_color normal)
  end
end