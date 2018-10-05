#!/usr/bin/env bash

# debug calls
shared_debug=${shared_debug:-0}

shared_git_sh_loaded=${shared_git_sh_loaded:-0}
if [ "x0" != "x${shared_git_sh_loaded}" ]; then
  if [ "x1" == "x${shared_debug}" ]; then
    echo "--> git.sh already included"
  fi
else
  shared_git_sh_loaded=1

  pkg::import logger
  
  git_result_new_commits=${git_result_new_commits:-}

  # Sets: git_result_new_commits
  # Assumes: $oldrev $newrev $refname
  #
  # This is for use in post receive hooks, as it assumes the refname has moved and
  # is now newrev, we need to discard it. This is down with bash string replace,
  # as it will replace only the first match, compared to the canonical "grep -v"
  # approach which will throw out multiple matches if the same commit is referred
  # to by multiple branches.
  #
  # Excellent, excellent docs from Andy Parkin's email script
  #
  ##################################################
  #
  # Consider this:
  #   1 --- 2 --- O --- X --- 3 --- 4 --- N
  #
  # O is $oldrev for $refname
  # N is $newrev for $refname
  # X is a revision pointed to by some other ref, for which we may
  #   assume that an email has already been generated.
  # In this case we want to issue an email containing only revisions
  # 3, 4, and N.  Given (almost) by
  #
  #  git rev-list N ^O --not --all
  #
  # The reason for the "almost", is that the "--not --all" will take
  # precedence over the "N", and effectively will translate to
  #
  #  git rev-list N ^O ^X ^N
  #
  # So, we need to build up the list more carefully.  git rev-parse
  # will generate a list of revs that may be fed into git rev-list.
  # We can get it to make the "--not --all" part and then filter out
  # the "^N" with:
  #
  #  git rev-parse --not --all | grep -v N
  #
  # Then, using the --stdin switch to git rev-list we have effectively
  # manufactured
  #
  #  git rev-list N ^O ^X
  #
  # This leaves a problem when someone else updates the repository
  # while this script is running.  Their new value of the ref we're
  # working on would be included in the "--not --all" output; and as
  # our $newrev would be an ancestor of that commit, it would exclude
  # all of our commits.  What we really want is to exclude the current
  # value of $refname from the --not list, rather than N itself.  So:
  #
  #  git rev-parse --not --all | grep -v $(git rev-parse $refname)
  #
  # Get's us to something pretty safe (apart from the small time
  # between refname being read, and git rev-parse running - for that,
  # I give up)
  #
  #
  # Next problem, consider this:
  #   * --- B --- * --- O ($oldrev)
  #          \
  #           * --- X --- * --- N ($newrev)
  #
  # That is to say, there is no guarantee that oldrev is a strict
  # subset of newrev (it would have required a --force, but that's
  # allowed).  So, we can't simply say rev-list $oldrev..$newrev.
  # Instead we find the common base of the two revs and list from
  # there.
  #
  # As above, we need to take into account the presence of X; if
  # another branch is already in the repository and points at some of
  # the revisions that we are about to output - we don't want them.
  # The solution is as before: git rev-parse output filtered.
  #
  # Finally, tags: 1 --- 2 --- O --- T --- 3 --- 4 --- N
  #
  # Tags pushed into the repository generate nice shortlog emails that
  # summarise the commits between them and the previous tag.  However,
  # those emails don't include the full commit messages that we output
  # for a branch update.  Therefore we still want to output revisions
  # that have been output on a tag email.
  #
  # Luckily, git rev-parse includes just the tool.  Instead of using
  # "--all" we use "--branches"; this has the added benefit that
  # "remotes/" will be ignored as well.
  #
  ##################################################
  git::set_new_commits() {
    logger::header "git::set_new_commits"

    refname=${refname:-}
    newrev=${newrev:-}
    oldrev=${oldrev:-}

    logger::log "refname: [${refname}]"
    logger::log "newrev:  [${newrev}]"
    logger::log "oldrev:  [${oldrev}]"

  	nl=$'\n'
  
  	# Get all the current branches, not'd as we want only new ones
  	git_result_new_commits=$(git rev-parse --not --branches || exit 0)
  
  	# Strip off the not current branch
  	new_hash=$(git rev-parse "${refname}" || exit 0)
  	git_result_new_commits=${git_result_new_commits/^$new_hash/}
  
  	# Put back newrev without the not
  	git_result_new_commits="${git_result_new_commits}${nl}${newrev}"
  
  	# Put in ^oldrev if it's not a new branch
  	if [ "${oldrev}" != "0000000000000000000000000000000000000000" ] ; then
  		git_result_new_commits="${git_result_new_commits}${nl}^${oldrev}"
  	fi
  
  	git_result_new_commits="${git_result_new_commits/$nl$nl/$nl}"
  	git_result_new_commits="${git_result_new_commits/#$nl/}"
  }

  git_result_change_type=${git_result_change_type:-}

  # Sets: $git_result_change_type
  # Assumes: $oldrev $newrev
  #
  # --- Interpret
  # 0000->1234 (create)
  # 1234->2345 (update)
  # 2345->0000 (delete)
  git::set_change_type() {
    logger::header "git::set_change_type"

    newrev=${newrev:-}
    oldrev=${oldrev:-}

    logger::log "newrev:  [${newrev}]"
    logger::log "oldrev:  [${oldrev}]"

  	if [ "${oldrev}" == "0000000000000000000000000000000000000000" ] ; then
  		git_result_change_type="create"
  	else
  		if [ "${newrev}" == "0000000000000000000000000000000000000000" ] ; then
  			git_result_change_type="delete"
  		else
  			git_result_change_type="update"
  		fi
  	fi
  }

  git_result_newrev_type=${git_result_newrev_type:-}
  git_result_oldrev_type=${git_result_oldrev_type:-}
  git_result_rev=${git_result_rev:-}
  git_result_rev_type=${git_result_rev_type:-}

  # Sets: $git_result_newrev_type $git_result_oldrev_type $git_result_rev $git_result_rev_type
  # Assumes: $newrev $oldrev
  # --- Get the revision types
  git::set_rev_types() {
    logger::header "git::set_rev_types"

    newrev=${newrev:-}
    oldrev=${oldrev:-}

    logger::log "newrev:  [${newrev}]"
    logger::log "oldrev:  [${oldrev}]"

  	git_result_newrev_type=$(git cat-file -t "${newrev}" 2> /dev/null || exit 0)
  	git_result_oldrev_type=$(git cat-file -t "${oldrev}" 2> /dev/null || exit 0)
  	if [ "${newrev}" == "0000000000000000000000000000000000000000" ] ; then
  		git_result_rev_type="${git_result_oldrev_type}"
  		git_result_rev="${oldrev}"
  	else
  		git_result_rev_type="${git_result_newrev_type}"
  		git_result_rev="${newrev}"
  	fi
  }

  git_result_describe=${git_result_describe:-}

  # Sets: $git_result_describe
  # Assumes: $rev
  #
  # The email subject will contain the best description of the ref that we can build from the parameters
  git::set_describe() {
    logger::header "git::set_describe"

    rev=${rev:-}

    logger::log "rev:  [${rev}]"

  	param=${1:-}
  	rev_to_describe="$rev"
  	if [ "${param}" != "" ] ; then
  		rev_to_describe="${param}"
  	fi
  
  	describe=$(git describe "${rev_to_describe}" 2>/dev/null || exit 0)
  	if [ -z "$describe" ]; then
  		git_result_describe=$rev_to_describe
  	fi
  }

  git_result_describe_tags=${git_result_describe_tags:-}

  # Sets: $git_result_describe_tags
  # Assumes: $rev
  #
  # The email subject will contain the best description of the ref that we can build from the parameters
  git::set_describe_tags() {
    logger::header "git::set_describe_tags"

    rev=${rev:-}

    logger::log "rev:  [${rev}]"

  	param=${1:-}
  	rev_to_describe="${rev}"
  	if [ "${param}" != "" ] ; then
  		rev_to_describe="${param}"
  	fi
  
  	git_result_describe_tags=$(git describe --tags "${rev_to_describe}" 2>/dev/null || exit 0)
  	if [ -z "${git_result_describe_tags}" ]; then
  		git_result_describe_tags=$rev_to_describe
  	fi
  }
fi