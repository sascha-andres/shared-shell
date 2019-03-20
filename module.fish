#! /usr/bin/env fish

set -q shared_module_loaded; or set -g shared_module_loaded 0
set -q shared_debug; or set -g shared_debug 0
set -q shared_install_location; or set -g shared_install_location "/opt/sascha-andres/shell"

set -g shared_loaded_modules

if test $shared_module_loaded -eq 0
  # set -u equivalent

  # shared_pipefail=${shared_pipefail:-1}
  # shared_exit_immediatly=${shared_exit_immediatly:-1}

  # if [ "x1" == "x${shared_debug}" ]; then
  #   set -x
  # fi
  # if [ "x1" == "x${shared_exit_immediatly}" ]; then
  #   set -e
  # fi
  # if [ "x1" == "x${shared_pipefail}" ]; then
  #   set -o pipefail
  # fi

  function pkg_module_loaded -d "list loaded modules"
    if count $argv
      set value $argv
      for mod in $shared_loaded_modules
        if [ "$mod" = "$value" ]
          return 0
        end
      end
    end
    return 1
  end

  function pkg_import -d "import a module"
    pkg_module_loaded $argv > /dev/null
    if test $status -ne 0
      if test -n $argv
        if test -e "$shared_install_location/$argv.fish"
          set -g shared_loaded_modules $shared_loaded_modules $argv
          . "$shared_install_location/$argv.fish"
          return 0
        else
          echo "!! import of module '$argv' failed !!"
        end
      else
        echo "!! you have to give a module !!"
      end
    end
    return 1
  end

end