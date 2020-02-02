#!/usr/bin/env bash

set -e

VERSION="1.0.0"
SELF=""
CS=""

TAR_START_MARK="____TAR_START_HERE____"

function info() {
    echo "${SELF:-cs-pack}: $@"
}

function err() {
    info "error: $@" 1>&2
}

function die() {
    err "$@"
    exit 1
}

function findCS() {
    local bin="$(which cs 2>/dev/null)"
    if [[ "$?" != 0 ]]; then
        return
    fi

    echo "$bin"
}

function extractImportPath() {
    local extPath="$1"
    local impPath="$(dirname $extPath)"
    echo "$impPath"
}

function require() {
    if ! which "$1" &>/dev/null; then
        die "$1 was required to run this package tool."
    fi
}

function check_env() {
    if [[ "${BASH_VERSINFO[0]}" != 4 ]]; then
        die "Bash4 was required to run this package tool."
    fi

    require "getopt"
    require "dirname"
    require "basename"
    require "cat"
    require "tar"
}

function do-help() {
    cat <<EOF
${SELF:-cs-pack}: The Covariant Script package tool, version $VERSION
Usage: ${SELF:-cs-pack} [options] <input>
This tool will pack <input> with its dependencies into a single executable.

  options:
    -o <file>   Set output file to <file>
    -s <file>   Set cs exectuable to <file>
    -h          Print help text
    -v          Print version

EOF
}

function initialize-dir() {
    local dir=".$$.cspack.tmp"
    rm -rf "$dir" &>/dev/null
    mkdir -p "${dir}/bin"
    mkdir -p "${dir}/imports"
    echo "$dir"
}

function add-bin() {
    local dir="$1"
    local file="$2"
    cp "$file" "${dir}/bin/"
}

function add-imports() {
    local dir="$1"
    local file="$2"
    cp "$file" "${dir}/imports/"
}

function create-wrapper() {
    cat <<EOF
#!/usr/bin/env bash

set -e

function die() {
    echo "\$@" 1>&2
    exit 1
}

function require() {
    if ! which "\$1" &>/dev/null; then
        die "\$1 was required to run this package tool."
    fi
}

function check_env() {
    if [[ "\${BASH_VERSINFO[0]}" != 4 ]]; then
        die "Bash4 was required to run this package tool."
    fi

    require "sed"
    require "tar"
    require "md5sum"
    require "cut"
}

check_env

EOF
}

function make-self-uncomp() {
    local exeName="$1"
    local runDir="/tmp/.cspack-${exeName}"
    local checkFile="${runDir}/checksum.md5"
    local exe="${runDir}/bin/${exeName}"
    local csExe="${runDir}/bin/cs"
    local importDir="${runDir}/imports"

cat <<EOF

self_md5="\$(md5sum \$0 | cut -d' ' -f1)"
local_md5="\$(cat $checkFile 2>/dev/null | cut -d' ' -f1)"

if [[ "\$self_md5"x != "\$local_md5"x ]]; then
    # do self uncompress
    rm -rf "$runDir" &>/dev/null
    mkdir -p "$runDir"
    sed '0,/^${TAR_START_MARK}$/d' \$0 | tar zx -C "$runDir"
    echo "\$self_md5" > "$checkFile"
fi

# run it
exec ${csExe} --import-path "${importDir}" "${exe}"

EOF
}

function make-self-exe() {
    echo "${TAR_START_MARK}"
    cat "$1"
}

function create-exe() {
    local output="$1"
    local tar="$2"
    local exeName="$3"

    create-wrapper               >  "$output"
    make-self-uncomp "$exeName"  >> "$output"
    make-self-exe "$tar"         >> "$output"
    chmod +x "$output"
}

function do-package() {
    local file="$1"
    local output="$2"

    if [[ ! -f "$file" ]]; then
        die "$file: no such file or directory"
    fi

    if [[ ! -x "$CS" ]]; then
        local cs="$(findCS)"
        if [[ ! -x "$cs" ]]; then
            err "cannot find cs binary, please specify -s option to tell me where it is."
            die "did you forget to make it executable?"
        fi

        CS="$cs"
    fi

    info "packing $file into $output"
    
    local dir="$(initialize-dir)"
    trap "rm -rf ${dir}" EXIT
    
    add-bin "$dir" "$file"
    add-bin "$dir" "$CS"

    while read line; do
        local tryP="${line}.csp"
        local tryE="${line}.cse"

        if [[ -r "$tryP" ]]; then
            add-imports "$dir" "$tryP"
        fi

        if [[ -r "$tryE" ]]; then
            add-imports "$dir" "$tryE"
        fi
    done <<< $($CS -r -c "$file")

    local outTar=".$$.cspack.tgz"
    rm -f "$outTar" &>/dev/null

    tar zcvf "$outTar" -C "$dir" .
    create-exe "$output" "$outTar" "$(basename $file)"
    rm -f "$outTar" &>/dev/null
}

function main() {
    check_env

    if [[ "$#" == 0 ]]; then
        err "no input file specified"
        do-help
        exit 1
    fi

    local opt="$(getopt o:s:h $@ 2>/dev/null)"
    eval set -- $opt

    local file=""
    local output=""

    while [[ ! -z "$1" ]];do
        case "$1" in
            "-o" ) 
                shift;
                output="$1"
                shift ;;
            
            "-s" )
                shift;
                CS="$1"
                shift ;;

            "-h" )
                shift;
                do-help
                exit 0 ;;

            * ) file="$1"
                shift ;;
        esac
    done

    if [[ "$file"x == ""x ]]; then
        die "no input file specified"
    fi

    if [[ "$output"x == ""x ]]; then
        output="$(basename $file)"
        output="${output%%.*}.cspack"
    fi

    do-package "$file" "$output"
}


SELF="${0##*/}"
main "$@"
