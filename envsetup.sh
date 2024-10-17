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
    local target=$1
    local variant=$2

    if [ $# -eq 0 ]; then
        # No arguments, so display the full menu
        lunch
    else
        # Handle target modification
        case "$target" in
            ev_*)  # If target already starts with 'ev_', no changes needed
                ;;
            !*)  # If target starts with '!', remove it but don't prepend 'ev_'
                target="${target:1}"
                ;;
            *)  # Prepend 'ev_' if not present and doesn't end with '!'
                target="ev_$target"
                ;;
        esac

        local release=$(cat vendor/ev/vars/aosp_target_release 2>/dev/null)

        # Run roomservice.py only if the target starts with 'ev_'
        if [[ "$target" =~ ^ev_ ]]; then
            local available=$(TARGET_PRODUCT=$target TARGET_RELEASE=$release TARGET_BUILD_VARIANT= TARGET_BUILD_TYPE= TARGET_BUILD_APPS= _get_build_var_cached TARGET_DEVICE 2>/dev/null)
            vendor/ev/build/tools/roomservice.py $target $([[ -n "$available" ]] && echo true)
        fi

        # Handle build types
        if [[ "$target" =~ -(user|userdebug|eng)$ ]]; then
            lunch $target
        else
            # Default to 'userdebug' if no variant specified
            variant=${variant:-"userdebug"}
            lunch $target-$release-$variant
        fi
    fi
    return $?
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
        PROJECT="build_repo"
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
    common_out_dir=$(_get_build_var_cached OUT_DIR)/target/common
    target_device=$(_get_build_var_cached TARGET_DEVICE)
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

function update_aosp_manifest() # <Tag> <sync jobs>
{
    if [ -z "$1" ]; then
        echo "Usage: update_aosp_tag <aosp-tag>"
        return 1
    fi

    local tag="$1"
    local top_dir=$(gettop)
    local manifest_dir="$top_dir/.repo/manifests"

    cd "$manifest_dir" || return 1
    git pull https://android.googlesource.com/platform/manifest $tag

    echo "Correct any errors to the manifest, press 'c' to continue"
    read -n 1 k <&1
    if [[ "$k" != "c" ]]; then
        echo "Operation canceled."
        return 1
    fi

    echo "Syncing the updated manifest..."
    cd "$top_dir" || return 1
    repo sync -c --force-sync
}

function update_aosp_forks() # <Tag> <max_jobs> [--dump-to-file <path/filename>]
{
    if [ -z "$1" ]; then
        echo "Usage: update_aosp_forks <aosp-tag> [<max_jobs>] [--dump-to-file <path/filename>]"
        return 1
    fi

    local tag="$1"
    local top_dir=$(gettop)
    local aosp_repos_file="$top_dir/.repo/manifests/snippets/aosp.xml"
    local job_count=0
    local max_jobs=$2
    local merge_repo_file="/tmp/merge_repos.txt"
    local dump_to_file=""

    if [ -z "$2" ]; then
        max_jobs=64
    fi

    # Check for additional arguments
    shift 2
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --dump-to-file)
                dump_to_file="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    declare -A skip_repos
    skip_list_file="$top_dir/vendor/ev/build/config/repo_skip_list.txt"  # Updated to use a valid variable name

    # Load skip list if provided
    if [ -n "$skip_list_file" ] && [ -f "$skip_list_file" ]; then
        while IFS=" - " read -r repo_pattern _ || [[ -n "$repo_pattern" ]]; do
            # Trim any leading/trailing whitespace from repo_pattern
            repo_pattern=$(echo "$repo_pattern" | xargs)
            skip_repos["$repo_pattern"]=1  # Store only the repo pattern in the array
        done < "$skip_list_file"
    fi

    echo "Starting to pull updates to our forked repos..."
    local aosp_repos=$(grep 'remote="evervolv"' "$aosp_repos_file" | awk '{print $2}' | awk -F '"' '{print $2}')

    for dir in ${aosp_repos}; do
        cd "$top_dir/$dir" || continue  # Use continue to skip this iteration if cd fails

        # Flag to check if the current repo should be skipped
        skip_repo=false

        # Check if repo matches a skip pattern in the skip list
        for repo_pattern in "${!skip_repos[@]}"; do
            if [[ "$dir" == $repo_pattern ]]; then
                echo "$dir - SKIPPED" >> "$merge_repo_file"
                continue 2
            fi
        done

        # If repo is not skipped, proceed with the pull operation
        aospremote

        # Attempt to pull from the AOSP tag
        if git pull aosp "$tag" --no-edit; then
            # Check if there was a merge and if it was clean
            if git log -1 | grep -q "Merge tag '$tag'"; then
                echo "Clean merge for repo: $dir"
                echo "$dir - CLEAN" >> "$merge_repo_file"
            fi
        else
            # If git pull failed, log it as a conflict
            echo "Merge conflict or issue for repo: $dir"
            echo "$dir - CONFLICT" >> "$merge_repo_file"
        fi
    done

    wait

    echo "Update complete."

    # Now read and categorize the merge results
    echo "Categorizing merge results..."

    # Arrays for different categories
    local clean_repos=()
    local conflict_repos=()
    local skipped_repos=()

    while IFS= read -r line; do
        case "$line" in
            *CLEAN*)
                clean_repos+=("${line/- CLEAN/}")
            ;;
            *CONFLICT*)
                conflict_repos+=("${line/- CONFLICT/}")
            ;;
            *SKIPPED*)
                skipped_repos+=("${line/- SKIPPED/}")
            ;;
        esac
    done < "$merge_repo_file"

    # Clear the merge file
    : > "$merge_repo_file"

    print_category() {
        local category_name="$1"
        shift
        local repos=("$@")

        echo "" | tee -a "$merge_repo_file"
        if [ ${#repos[@]} -ne 0 ]; then
            echo "Repositories with $category_name merges:" | tee -a "$merge_repo_file"
            for repo in "${repos[@]}"; do
                echo "$repo" | tee -a "$merge_repo_file"
            done
        else
            echo "No $category_name merges detected." | tee -a "$merge_repo_file"
        fi
    }

    # Print categorized results
    print_category "CONFLICT" "${conflict_repos[@]}"
    echo "------------------------------------------------ " | tee -a "$merge_repo_file"
    print_category "SKIPPED" "${skipped_repos[@]}"
    echo "------------------------------------------------ " | tee -a "$merge_repo_file"
    print_category "CLEAN" "${clean_repos[@]}"
    echo "------------------------------------------------ " | tee -a "$merge_repo_file"

    # If dump_to_file is set, copy the merge results to the specified file
    if [ -n "$dump_to_file" ]; then
        cp "$merge_repo_file" "$dump_to_file"
        echo "Merge results have been copied to $dump_to_file"
    fi

    # Clean up the temporary file
    rm -f "$merge_repo_file"

    cd "$top_dir"
    return 0

}

# Add hooks from repo
git config --global core.hooksPath $(gettop)/.repo/repo/hooks

# Override host metadata to make builds more reproducible and avoid leaking info
export BUILD_USERNAME=nobody
export BUILD_HOSTNAME=android-build
