#!/bin/bash

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# Copyright (c) 2014, Toni Dietze
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. Neither the name of the author nor the names of his contributors
#    may be used to endorse or promote products derived from this software
#    without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHORS AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

set -Ceu


function printHelp {
cat <<EOF
Usage: ${0##*/} [-c] [-m] [-- <GIT OPTIONS>]

Commit current index backdated to the time of the last change/modification of
any indexed file. You may pass arbitrary options to git via <GIT OPTIONS>.

  -c   take change time into account
  -m   take modification time into account
  -h   show this help
EOF
}

[ "${#}" -le 0 ] && { printHelp; exit 1; }


# http://stackoverflow.com/questions/957928/is-there-a-way-to-get-the-git-root-directory-in-one-command
cd "$(git rev-parse --show-toplevel)"

C=false
M=false
while [ "${#}" -ge 1 ]
do
	case "${1}" in
		(-*h*) printHelp; exit ;;
		(-*c*) C=true ;;&
		(-*m*) M=true ;;&
		(--  ) shift; break;;
	esac
	shift
done

exec 3<&0

# Idea from: http://stackoverflow.com/a/14300605
<&- git diff --name-only --cached  \
|	while read
	do
		"${C}" && stat -c '%Z %% %z %% changed  %% %n' "${REPLY}"
		"${M}" && stat -c '%Y %% %y %% modified %% %n' "${REPLY}"
	done  \
| sort -n  \
| {
		while read
		do
			if [[ "${REPLY}" =~ ^([^%]*)\ %\ ([^%]*)\ %\ ([^%]*)\ %\ ([^%]*)$  ]]
			then
				echo "${BASH_REMATCH[2]}: ${BASH_REMATCH[3]} ${BASH_REMATCH[4]}"
			fi
		done
		CMD=(git commit --date="${BASH_REMATCH[2]}" "${@}")
		{	read -p "${CMD[*]} "
			set -x
			"${CMD[@]}"
		} <&3
	}
