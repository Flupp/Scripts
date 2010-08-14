#!/bin/bash

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# Copyright (c) 2009-2010, Toni Dietze
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
# 2009-11-13
# + initial release
#
# 2010-05-30
# + added parameters to constraint the age of the logs
# * changed formatting
# * changed date retrieval
#
# 2010-07-08
# + added option do specify the log level
#

set -e -u

LOGDIR='/var/log/paludis'
LOGAFTER='0'
LOGBEFORE='1000000000000'
LOGLEVELPARAM='I'

function printHelp() {
cat <<EOF
${0##*/} [-a <date-after>] [-b <date-before>] [-c <hours>] [-t] [-d <directory>]
  --after <date-after>, -a <date-after>
  --before <date-before>, -b <date-before>
    Only show logs which are older than <date-after> and
    newer than <date-before>.
  --current <hours>, -c <hours>
    Set --after to the current time minus <hours> hours.
  --today, -t
    Set --after such that only logs from today are shown.
  --loglevel <level>
    Sets the log level. <level> can be one of E, W, L or I. Default: ${LOGLEVELPARAM}
  --logdir <directory>, -d <directory>
    Directory where to look for the log files.
    Default: ${LOGDIR}
EOF
}

while [ "$#" -gt 0 ]
do
	case "$1" in
		(-a | --after    ) shift; LOGAFTER="$(date -d "${1?\"--after\" expects one parameter.}" +'%s')"; shift;;
		(-b | --before   ) shift; LOGBEFORE="$(date -d "${1?\"--before\" expects one parameter.}" +'%s')"; shift;;
		(-c | --current  ) shift; LOGAFTER="$(($(date +'%s') - 3600 * (${1?\"--current\" expects one parameter.})))"; shift;;
		(-t | --today    ) shift; LOGAFTER="$(date -d "$(date +'%Y-%m-%d')" +'%s')";;
		(     --loglevel ) shift; LOGLEVELPARAM="${1?\"--loglevel\" expects one parameter.}"; shift;;
		(-d | --logdir   ) shift; LOGDIR="${1?\"--logdir\" expects one parameter.}"; shift;;
		(-h | --help     ) printHelp; exit 0;;
		(-l | --license  ) head -n 31 "${0}" | tail -n +5; exit 0;;
		(*               ) printHelp; exit 1;;
	esac
done

case "${LOGLEVELPARAM}" in
	(E|e) LOGLEVEL=1; LOGLEVELGREP='^I\|^L\|^W' ;;
	(W|w) LOGLEVEL=2; LOGLEVELGREP='^I\|^L' ;;
	(L|l) LOGLEVEL=3; LOGLEVELGREP='^I' ;;
	(I|i) LOGLEVEL=4; LOGLEVELGREP='$^' ;;
	(*  ) echo '"--loglevel" expects parameter E, W, L or I' >&2; exit 1;;
esac

# from /usr/libexec/paludis/echo_functions.bash
COLOUR_GREEN=$'\e[32;01m'
COLOUR_YELLOW=$'\e[33;01m'
COLOUR_RED=$'\e[31;01m'
COLOUR_BLUE=$'\e[34;01m'
COLOUR_PINK=$'\e[35;01m'
COLOUR_CYAN=$'\e[36;01m'
COLOUR_BROWN=$'\e[33m'
COLOUR_PURPLE=$'\e[35m'
COLOUR_DARK_BLUE=$'\e[34m'

COLOUR_NORMAL=$'\e[0m'

COL_I="${COLOUR_NORMAL}"
COL_L="${COLOUR_GREEN}"
COL_W="${COLOUR_YELLOW}"
COL_E="${COLOUR_RED}"

COL_DATE="\033[1;37m"
COL_ACTION="${COLOUR_CYAN}"
COL_PACKAGE="${COLOUR_GREEN}"

for I in "${LOGDIR}"/*.messages
do
	PKG="${I##*/}"
	TIMESTAMP="${PKG%%-*}"

	if [ "${TIMESTAMP}" -lt "${LOGAFTER}" ] \
	|| [ "${TIMESTAMP}" -gt "${LOGBEFORE}" ] ; then
		continue
	fi

	PKG="${PKG#*-}"
	ACTION="${PKG%%-*}"
	PKG="${PKG#*-}"
	PKG="${PKG%.messages}"
	PKG="${PKG/_//}"

	if [ "${LOGLEVEL}" -ge 4 ] || grep -v -e "${LOGLEVELGREP}" -q "${I}"
	then
		echo -e "${COL_DATE}$(date -d "1970-01-01 ${TIMESTAMP} sec GMT" +'%Y-%m-%d %H:%M:%S') ${COL_ACTION}${ACTION} ${COL_PACKAGE}${PKG}${COLOUR_NORMAL}"
		echo "         ${I##*/}"
		echo
		while read L ; do
			case "${L:0:1}" in
				('I') [ "${LOGLEVEL}" -ge 4 ] && { echo -en "${COL_I}${L:0:1}${COLOUR_NORMAL}"; echo "${L:1}"; } ;;
				('L') [ "${LOGLEVEL}" -ge 3 ] && { echo -en "${COL_L}${L:0:1}${COLOUR_NORMAL}"; echo "${L:1}"; } ;;
				('W') [ "${LOGLEVEL}" -ge 2 ] && { echo -en "${COL_W}${L:0:1}${COLOUR_NORMAL}"; echo "${L:1}"; } ;;
				('E') [ "${LOGLEVEL}" -ge 1 ] && { echo -en "${COL_E}${L:0:1}${COLOUR_NORMAL}"; echo "${L:1}"; } ;;
				(*  ) echo "${L}" ;;
			esac
		done <"${I}"
		echo
	fi
done
