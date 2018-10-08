#! /usr/bin/env fish

set -q shared_module_loaded; or set -g shared_module_loaded 0

if math $shared_module_loaded == 0 > /dev/null
  # set -u equivalent

  set -q shared_install_location; or set -g shared_install_location "/opt/sascha-andres/shell"
  set -q shared_debug; or set -g shared_debug 0
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

  set -g shared_loaded_modules

  function shared_module_loaded -d "list loaded modules"
    if count $argv > /dev/null
      set value $argv[0]
      for mod in $shared_loaded_modules
        if "x$mod" == "x$value"
          return 0
        end
      end
    end
    return 2
  end

  function shared_import -d "import a module"
    shared_module_loaded $argv
    if math $status != 0 > /dev/null
      if test -n $argv
        if test -e "$shared_install_location/$module.fish"
          set -g shared_loaded_modules=($shared_loaded_modules $argv)
          . "$shared_install_location/$argv.fish"
          return 0
        else
          echo "!! import of module '$argv' failed !!"
        end
      else
        echo "!! you have to give a module !!"
      end
    end
    return 2
  end

end