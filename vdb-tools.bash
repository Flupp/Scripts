#!/bin/bash

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# Copyright (c) 2010, Toni Dietze
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
#
# 2010-09-16
# + initial release
#

set -e -u -C

function printHelp() {
cat <<EOF
${0##*/} list [<regex>]
${0##*/} untracked
${0##*/} untracked-la-files
${0##*/} license
EOF
}

function vdb-list() {
	S='.*'
	if [ "${#}" -ne 0 ]
	then
		S="${*}"
	fi
	cat /var/db/pkg/*/*/CONTENTS \
	| sed -n "s#^obj \(${S}\) [^ ]* [^ ]*\$\|^dir \(${S}\)\$\|^sym \(${S}\) -> .* [^ ]*\$#\1\2\3#p" \
	| sort \
	| uniq
}

function vdb-dead-la-files() {
	diff <(vdb-list '.*\.la' | sort | uniq) <(locate -r "\.la$" | sort | uniq) \
	| sed -n 's#^> \(.*\)$#\1#p'
}

function vdb-untracked() {
	diff \
		<(vdb-list) \
		<(find $(vdb-list | sed -n 's#^\(/[^/]*\)/.*$#\1#p' | uniq) \
		  | grep -v '^/usr/portage/\|^/var/cache/\|^/var/db/pkg/' \
		  | sort \
		 )
}


if [ "${#}" -eq 0 ]
then
	printHelp
	exit
fi


P="${1}"
shift
case "${P}" in
	(list) vdb-list "${@}" ;;
	(untracked) vdb-untracked ;;
	(untracked-la-files) vdb-dead-la-files ;;
	(license) head -n 31 "${0}" | tail -n +5 ;;
	(*) printHelp ;;
esac
