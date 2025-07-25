# shellcheck shell=bash
cite about-plugin
about-plugin 'one command to extract them all...'

# extract file(s) from compressed status
extract() {
	local opt
	local OPTIND=1
	while getopts "hv" opt; do
		case "$opt" in
			h)
				cat << End-Of-Usage
Usage: ${FUNCNAME[0]} [option] <archives>
    options:
        -h  show this message and exit
        -v  verbosely list files processed
End-Of-Usage
				return
				;;
			v)
				local -r verbose='v'
				;;
			?)
				extract -h >&2
				return 1
				;;
		esac
	done
	shift $((OPTIND - 1))

	if [[ $# -eq 0 ]]; then
		extract -h
		return 1
	fi

	while [[ $# -gt 0 ]]; do
		if [[ ! -f "${1:-}" ]]; then
			echo "extract: '$1' is not a valid file" >&2
			shift
			continue
		fi

		local -r filename=$(basename -- "$1")
		local -r filedirname=$(dirname -- "$1")
		local targetdirname
		# shellcheck disable=SC2001 # we don't depend on `extglob`...
		targetdirname=$(sed 's/\(\.tar\.bz2$\|\.tbz$\|\.tbz2$\|\.tar\.gz$\|\.tgz$\|\.tar$\|\.tar\.xz$\|\.txz$\|\.tar\.Z$\|\.7z$\|\.nupkg$\|\.zip$\|\.war$\|\.jar$\)//g' <<< "$filename")
		if [[ "$filename" == "$targetdirname" ]]; then
			# archive type either not supported or it doesn't need dir creation
			targetdirname=""
		else
			mkdir -v "$filedirname/$targetdirname"
		fi

		if [[ -f "$1" ]]; then
			case "$1" in
				*.tar.bz2 | *.tbz | *.tbz2) tar "x${verbose}jf" "$1" -C "$filedirname/$targetdirname" ;;
				*.tar.gz | *.tgz) tar "x${verbose}zf" "$1" -C "$filedirname/$targetdirname" ;;
				*.tar.xz | *.txz) tar "x${verbose}Jf" "$1" -C "$filedirname/$targetdirname" ;;
				*.tar.Z) tar "x${verbose}Zf" "$1" -C "$filedirname/$targetdirname" ;;
				*.bz2) bunzip2 "$1" ;;
				*.deb) dpkg-deb -x"${verbose}" "$1" "${1:0:-4}" ;;
				*.pax.gz)
					gunzip "$1"
					set -- "$@" "${1:0:-3}"
					;;
				*.gz) gunzip "$1" ;;
				*.pax) pax -r -f "$1" ;;
				*.pkg) pkgutil --expand "$1" "${1:0:-4}" ;;
				*.rar) unrar x "$1" ;;
				*.rpm) rpm2cpio "$1" | cpio -idm"${verbose}" ;;
				*.tar) tar "x${verbose}f" "$1" -C "$filedirname/$targetdirname" ;;
				*.xz) xz --decompress "$1" ;;
				*.zip | *.war | *.jar | *.nupkg) unzip "$1" -d "$filedirname/$targetdirname" ;;
				*.Z) uncompress "$1" ;;
				*.7z) 7za x -o"$filedirname/$targetdirname" "$1" ;;
				*) echo "'$1' cannot be extracted via extract" >&2 ;;
			esac
		fi

		shift
	done
}

# Shorten extract
alias xt='extract'
