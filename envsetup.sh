function __print_ev_functions_help() {
cat <<EOF
Additional Evervolv functions:
- find_deps:       Roomservice utility to fetch device dependencies.
- purge_deps:      Utility to remove tracked repos from roomservice. (Keeps local history)
- cleantree:       Wipes local changes from git repository.
- aospremote:      Add git remote for matching AOSP repository.
- cafremote:       Add git remote for matching CodeAurora repository.
- evgerrit:        A Git wrapper that fetches/pushes patch from/to Evervolv Gerrit Review.
- repodiff:        Utility to fetch diff logs between branches.
- repolog:         Utility to fetch diff logs between branches between different remotes.
- repopick:        Utility to fetch changes from Gerrit.
EOF
}

function find_deps() {

    if [ -z "$TARGET_PRODUCT" ]
    then
        echo "TARGET_PRODUCT not set..."
        lunch
    fi

    vendor/ev/build/tools/roomservice.py $TARGET_PRODUCT true
    if [ $? -ne 0 ]
    then
        echo "find_deps failed."
    fi
}

function purge_deps() {
    read -p "Are you sure you want to remove roomservice repos? (y|N)" ans
    test "$ans" = "Y" || test "$ans" = "y" || return
    if [ ! "$ANDROID_BUILD_TOP" ]; then
        export ANDROID_BUILD_TOP=$(gettop)
    fi
    if [ "$(pwd)" != "$ANDROID_BUILD_TOP" ]; then
        cd "$ANDROID_BUILD_TOP"
    fi
    if [ ! -d .repo ]; then
        echo .repo directory not found.
    fi
    rm -rf .repo/local_manifests/
    echo "Local manifests removed, syncing so repo removes them"
    repo sync -fd >/dev/null 2>&1
    echo "Done"
}

function breakfast()
{
    lunch $@
}

function cleantree () {
    read -p "Are you sure you want to erase local changes? (y|N)" ans
    test "$ans" = "Y" || test "$ans" = "y" || return
    if [ ! "$ANDROID_BUILD_TOP" ]; then
        export ANDROID_BUILD_TOP=$(gettop)
    fi
    if [ "$(pwd)" != "$ANDROID_BUILD_TOP" ]; then
        cd "$ANDROID_BUILD_TOP"
    fi
    echo "Cleaning tree...This will take a few minutes"
    repo forall -c git reset --hard >/dev/null 2>&1
    repo forall -c git clean -fd >/dev/null 2>&1
    repo sync -fd >/dev/null 2>&1
    echo "Done"
}

function aospremote() {
    git remote rm aosp 2> /dev/null
    if [ ! -d .git ]
    then
        echo .git directory not found. Please run this from the root directory of the Android repository you wish to set up.
    fi
    if [ ! "$ANDROID_BUILD_TOP" ]; then
        export ANDROID_BUILD_TOP=$(gettop)
    fi
    local PROJECT=$(pwd -P | sed -e "s#$ANDROID_BUILD_TOP\/##; s#-caf.*##; s#\/default##; s#PermissionController#PackageInstaller#")
    # Google moved the repo location in Oreo
    if [ $PROJECT = "build/make" ]
    then
        PROJECT="build"
    fi
    if (echo $PROJECT | grep -qv "^device")
    then
        if (echo $PROJECT | grep -qv "^kernel")
        then
            local PFX="platform/"
        fi
    fi
    git remote add aosp https://android.googlesource.com/$PFX$PROJECT
    echo "Remote 'aosp' created"
}
export -f aospremote

function cafremote()
{
    git remote rm caf 2> /dev/null
    if [ ! -d .git ]
    then
        echo .git directory not found. Please run this from the root directory of the Android repository you wish to set up.
    fi
    if [ ! "$ANDROID_BUILD_TOP" ]; then
        export ANDROID_BUILD_TOP=$(gettop)
    fi
    local PROJECT=$(pwd -P | sed -e "s#$ANDROID_BUILD_TOP\/##; s#-caf.*##; s#\/default##; s#PermissionController#PackageInstaller#; s#Gallery2#SnapdragonGallery#; s#Snap\$#SnapdragonCamera#")
    # Google moved the repo location in Oreo
    if [ $PROJECT = "build/make" ]
    then
        PROJECT="build"
    fi
    if [[ $PROJECT =~ "qcom/opensource" ]];
    then
        PROJECT=$(echo $PROJECT | sed -e "s#qcom\/opensource#qcom-opensource#")
    fi
    if (echo $PROJECT | grep -qv "^device")
    then
        if (echo $PROJECT | grep -qv "^kernel")
        then
            local PFX="platform/"
        fi
    fi
    git remote add caf https://git.codelinaro.org/clo/la/$PFX$PROJECT
    echo "Remote 'caf' created"
}
export -f cafremote

function evgerrit() {
    if [ $# -eq 0 ]; then
        $FUNCNAME help
        return 1
    fi
    local user=`git config --get evreview.review.evervolv.com.username`
    local review=`git config --get remote.github.review`
    local project=`git config --get remote.github.projectname`
    local command=$1
    shift
    case $command in
        help)
            if [ $# -eq 0 ]; then
                cat <<EOF
Usage:
    $FUNCNAME COMMAND [OPTIONS] [CHANGE-ID[/PATCH-SET]][{@|^|~|:}ARG] [-- ARGS]

Commands:
    fetch   Just fetch the change as FETCH_HEAD
    help    Show this help, or for a specific command
    pull    Pull a change into current branch
    push    Push HEAD or a local branch to Gerrit for a specific branch

Any other Git commands that support refname would work as:
    git fetch URL CHANGE && git COMMAND OPTIONS FETCH_HEAD{@|^|~|:}ARG -- ARGS

See '$FUNCNAME help COMMAND' for more information on a specific command.

Example:
    $FUNCNAME checkout -b topic 1234/5
works as:
    git fetch http://DOMAIN/p/PROJECT refs/changes/34/1234/5 \\
      && git checkout -b topic FETCH_HEAD
will checkout a new branch 'topic' base on patch-set 5 of change 1234.
Patch-set 1 will be fetched if omitted.
EOF
                return
            fi
            case $1 in
                __evg_*) echo "For internal use only." ;;
                changes|for)
                    if [ "$FUNCNAME" = "evgerrit" ]; then
                        echo "'$FUNCNAME $1' is deprecated."
                    fi
                    ;;
                help) $FUNCNAME help ;;
                fetch|pull) cat <<EOF
usage: $FUNCNAME $1 [OPTIONS] CHANGE-ID[/PATCH-SET]

works as:
    git $1 OPTIONS http://DOMAIN/p/PROJECT \\
      refs/changes/HASH/CHANGE-ID/{PATCH-SET|1}

Example:
    $FUNCNAME $1 1234
will $1 patch-set 1 of change 1234
EOF
                    ;;
                push) cat <<EOF
usage: $FUNCNAME push [OPTIONS] [LOCAL_BRANCH:]REMOTE_BRANCH

works as:
    git push OPTIONS ssh://USER@DOMAIN:29418/PROJECT \\
      {LOCAL_BRANCH|HEAD}:refs/for/REMOTE_BRANCH

Example:
    $FUNCNAME push fix6789:gingerbread
will push local branch 'fix6789' to Gerrit for branch 'gingerbread'.
HEAD will be pushed from local if omitted.
EOF
                    ;;
                *)
                    $FUNCNAME __evg_err_not_supported $1 && return
                    cat <<EOF
usage: $FUNCNAME $1 [OPTIONS] CHANGE-ID[/PATCH-SET][{@|^|~|:}ARG] [-- ARGS]

works as:
    git fetch http://DOMAIN/p/PROJECT \\
      refs/changes/HASH/CHANGE-ID/{PATCH-SET|1} \\
      && git $1 OPTIONS FETCH_HEAD{@|^|~|:}ARG -- ARGS
EOF
                    ;;
            esac
            ;;
        __evg_get_ref)
            $FUNCNAME __evg_err_no_arg $command $# && return 1
            local change_id patchset_id hash
            case $1 in
                */*)
                    change_id=${1%%/*}
                    patchset_id=${1#*/}
                    ;;
                *)
                    change_id=$1
                    patchset_id=1
                    ;;
            esac
            hash=$(($change_id % 100))
            case $hash in
                [0-9]) hash="0$hash" ;;
            esac
            echo "refs/changes/$hash/$change_id/$patchset_id"
            ;;
        fetch|pull)
            $FUNCNAME __evg_err_no_arg $command $# help && return 1
            $FUNCNAME __evg_err_not_repo && return 1
            local change=$1
            shift
            git $command $@ http://$review/p/$project \
                $($FUNCNAME __evg_get_ref $change) || return 1
            ;;
        push)
            $FUNCNAME __evg_err_no_arg $command $# help && return 1
            $FUNCNAME __evg_err_not_repo && return 1
            if [ -z "$user" ]; then
                echo >&2 "Gerrit username not found."
                return 1
            fi
            local local_branch remote_branch
            case $1 in
                *:*)
                    local_branch=${1%:*}
                    remote_branch=${1##*:}
                    ;;
                *)
                    local_branch=HEAD
                    remote_branch=$1
                    ;;
            esac
            shift
            git push $@ ssh://$user@$review:8082/$project \
                $local_branch:refs/for/$remote_branch || return 1
            ;;
        changes|for)
            if [ "$FUNCNAME" = "evgerrit" ]; then
                echo >&2 "'$FUNCNAME $command' is deprecated."
            fi
            ;;
        __evg_err_no_arg)
            if [ $# -lt 2 ]; then
                echo >&2 "'$FUNCNAME $command' missing argument."
            elif [ $2 -eq 0 ]; then
                if [ -n "$3" ]; then
                    $FUNCNAME help $1
                else
                    echo >&2 "'$FUNCNAME $1' missing argument."
                fi
            else
                return 1
            fi
            ;;
        __evg_err_not_repo)
            if [ -z "$review" -o -z "$project" ]; then
                echo >&2 "Not a reviewable repository."
            else
                return 1
            fi
            ;;
        __evg_err_not_supported)
            $FUNCNAME __evg_err_no_arg $command $# && return
            case $1 in
                #TODO: filter more git commands that don't use refname
                init|add|rm|mv|status|clone|remote|bisect|config|stash)
                    echo >&2 "'$FUNCNAME $1' is not supported."
                    ;;
                *) return 1 ;;
            esac
            ;;
    #TODO: other special cases?
        *)
            $FUNCNAME __evg_err_not_supported $command && return 1
            $FUNCNAME __evg_err_no_arg $command $# help && return 1
            $FUNCNAME __evg_err_not_repo && return 1
            local args="$@"
            local change pre_args refs_arg post_args
            case "$args" in
                *--\ *)
                    pre_args=${args%%-- *}
                    post_args="-- ${args#*-- }"
                    ;;
                *) pre_args="$args" ;;
            esac
            args=($pre_args)
            pre_args=
            if [ ${#args[@]} -gt 0 ]; then
                change=${args[${#args[@]}-1]}
            fi
            if [ ${#args[@]} -gt 1 ]; then
                pre_args=${args[0]}
                for ((i=1; i<${#args[@]}-1; i++)); do
                    pre_args="$pre_args ${args[$i]}"
                done
            fi
            while ((1)); do
                case $change in
                    ""|--)
                        $FUNCNAME help $command
                        return 1
                        ;;
                    *@*)
                        if [ -z "$refs_arg" ]; then
                            refs_arg="@${change#*@}"
                            change=${change%%@*}
                        fi
                        ;;
                    *~*)
                        if [ -z "$refs_arg" ]; then
                            refs_arg="~${change#*~}"
                            change=${change%%~*}
                        fi
                        ;;
                    *^*)
                        if [ -z "$refs_arg" ]; then
                            refs_arg="^${change#*^}"
                            change=${change%%^*}
                        fi
                        ;;
                    *:*)
                        if [ -z "$refs_arg" ]; then
                            refs_arg=":${change#*:}"
                            change=${change%%:*}
                        fi
                        ;;
                    *) break ;;
                esac
            done
            $FUNCNAME fetch $change \
                && git $command $pre_args FETCH_HEAD$refs_arg $post_args \
                || return 1
            ;;
    esac
}

function repodiff() {
    if [ -z "$*" ]; then
        echo "Usage: repodiff <ref-from> [[ref-to] [--numstat]]"
        return
    fi
    diffopts=$* repo forall -c \
      'echo "$REPO_PATH ($REPO_REMOTE)"; git diff ${diffopts} 2>/dev/null ;'
}

function repolog() {
	local usage=$(cat <<-EOF
	usage: repolog branch branch [opts]
	    opts:
	        -r|--reverse     : reverse log
	        --full           : omit --oneline
	        -g|--github      : only show projects with github remote
		-a|--aosp        : only show projects with aosp remote
	examples:
	        repolog github/kitkat HEAD --full
	        repolog android-4.4_r1 android-4.4_r1.1 -r -a

	EOF
	)
	local gitopts="--oneline"
	local github=0
	local aosp=0
	if [ $# -lt 2 ]; then
		echo "$usage"
		return 1
	fi
	local branch1=$1; shift;
	local branch2=$1; shift;
	while [ $# -gt 0 ]; do
		case $1 in
			-r|--reverse)
				gitopts+=" --reverse";;
			--full)
				gitopts=${gitopts/--oneline/};;
			-g|--github)
				github=1;;
			-a|--aosp)
				aosp=1;;
			-h|--help)
				echo "$usage"; return 1;;
		esac
		shift
	done
	if [ "${branch1#github}" != "$branch1" ] || \
		[ "${branch2#github}" != "$branch2" ]; then
	       github=1
	fi
	if [ $github -eq 1 ]; then
		gopt=$gitopts br1=$branch1 br2=$branch2 repo forall -pvc 'if [ "$(git config --get remote.github.url)" ]; then git log ${gopt} ${br1}..${br2}; fi;'
	elif [ $aosp -eq 1 ]; then
		gopt=$gitopts br1=$branch1 br2=$branch2 repo forall -pvc 'if [ "$(git config --get remote.aosp.url)" ]; then git log ${gopt} ${br1}..${br2}; fi;'
	else
		gopt=$gitopts br1=$branch1 br2=$branch2 repo forall -pvc 'git log ${gopt} ${br1}..${br2}'
	fi
}

function repopick() {
    T=$(gettop)
    $T/vendor/ev/build/tools/repopick.py $@
}

function fixup_common_out_dir() {
    common_out_dir=$(get_build_var OUT_DIR)/target/common
    target_device=$(get_build_var TARGET_DEVICE)
    common_target_out=common-${target_device}
    if [ ! -z $EV_FIXUP_COMMON_OUT ]; then
        if [ -d ${common_out_dir} ] && [ ! -L ${common_out_dir} ]; then
            mv ${common_out_dir} ${common_out_dir}-${target_device}
            ln -s ${common_target_out} ${common_out_dir}
        else
            [ -L ${common_out_dir} ] && rm ${common_out_dir}
            mkdir -p ${common_out_dir}-${target_device}
            ln -s ${common_target_out} ${common_out_dir}
        fi
    else
        [ -L ${common_out_dir} ] && rm ${common_out_dir}
        mkdir -p ${common_out_dir}
    fi
}

function update_aosp_tag() # <Tag>
{
    if [ -z "$1" ]; then
        echo "Usage: update_aosp_tag <aosp-tag>"
        return
    fi

    T=$(gettop)
    cd $T/.repo/manifests
    git pull https://android.googlesource.com/platform/manifest refs/tags/$1

    echo "Correct any errors to the manifest, press 'c' to continue"
    read -n 1 k <&1
    if [[ $k = c ]] ; then
        echo "Sync the updated manifest"
        cd $T
        repo sync -c --force-sync

        echo "Start pulling updates to our forked repos"
        local AOSP_REPOS=$(cat $T/android/snippets/aosp.xml | grep 'remote="evervolv"' | awk '{print $2}' | awk -F '"' '{print $2}')
        for dir in ${AOSP_REPOS}; do
            cd $T/${dir}
            case ${dir} in
            prebuilts/* | packages/apps/Gallery2)
            ;;
            *)
                aospremote
                git pull aosp refs/tags/$1
            ;;
            esac
        done

        echo "Update complete, fix any conflicts present after merging"
        cd $T
        return
    fi
}

# Add hooks from repo
git config --global core.hooksPath $(gettop)/.repo/repo/hooks
