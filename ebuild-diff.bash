#!/bin/bash

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# Copyright (c) 2009, Toni Dietze
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

set -e -u

INSTALLED='/var/db/pkg'
TREE='/usr/portage'

function printHelp() {
cat <<EOF
${0##*/} [-c] [-r] [-d] [-i <installed-path>] [-t <tree-path>]
  --changed, -c
    print changed ebuilds to stdout
  --removed, -r
    print removed ebuilds to stdout
  --diff, -d
    print differences in changed ebuilds using colordiff to stdout,
    implies -c
  --installed <installed-path>, -i <installed-path>
    set path to directory containing the db of the installed packages
    default: ${INSTALLED}
  --tree <tree-path>, -t <tree-path>
    set path to portage tree or equivalent (overlay, etc.)
    default: ${TREE}
  --license, -l
    print license to stdout
  --help, -h
    print this help to stdout

  This script helps to find ebuilds whose installed version differs from the
  version in the (portage) tree. Ebuilds with changed comments or KEYWORDS are
  ignored.
EOF
}

SHOW_CHANGED=0
SHOW_DIFF=0
SHOW_REMOVED=0
while [ "$#" -gt 0 ]
do
	case "$1" in
		(-c | --changed  ) shift; SHOW_CHANGED=1;;
		(-d | --diff     ) shift; SHOW_CHANGED=1; SHOW_DIFF=1;;
		(-r | --removed  ) shift; SHOW_REMOVED=1;;
		(-i | --installed) shift; INSTALLED="${1?\"--installed\" expects one parameter.}"; shift;;
		(-t | --tree     ) shift; TREE="${1?\"--tree\" expects one parameter.}"; shift;;
		(-h | --help     ) printHelp; exit 0;;
		(-l | --license  ) head -n 31 "${0}" | tail -n +5; exit 0;;
		(*               ) printHelp; exit 1;;
	esac
done

if [ "${SHOW_CHANGED}" -eq 0 ] && [ "${SHOW_REMOVED}" -eq 0 ]
then
	echo 'at least one option of -c, -r or -d must be set' >&2
	echo
	printHelp
	exit 1
fi

FILTER='^\s*#.*\|^\s*KEYWORDS=.*'

for CATEGORY in "${INSTALLED}"/*
do
	CAT=${CATEGORY##*/}
	for PACKAGE in "${CATEGORY}"/*
	do
		PKG=${PACKAGE##*/}
		PKG=${PKG%-[0123456789]*}
		for EBUILD in "${PACKAGE}"/*.ebuild
		do
			EBD=${EBUILD##*/}
			if [ -e "${TREE}/${CAT}/${PKG}/${EBD}" ]
			then
				if [ ${SHOW_CHANGED} -ne 0 ]
				then
					RET=0
					if [ ${SHOW_DIFF} -ne 0 ]
					then
						colordiff <(grep -v -e "${FILTER}" "${EBUILD}") <(grep -v -e "${FILTER}" "${TREE}/${CAT}/${PKG}/${EBD}") || RET="${?}"
					else
						diff --brief <(grep -v -e "${FILTER}" "${EBUILD}") <(grep -v -e "${FILTER}" "${TREE}/${CAT}/${PKG}/${EBD}") > /dev/null || RET="${?}"
					fi
					if [ "${RET}" -ne 0 ]
					then
						echo "=${CAT}/${EBD%.*}"
					fi
				fi
			else
				if [ ${SHOW_REMOVED} -ne 0 ] && [ "${EBUILD}" != "${PACKAGE}/*.ebuild" ]
				then
					echo "=${CAT}/${EBD%.*}"
				fi
			fi
		done
	done
done
