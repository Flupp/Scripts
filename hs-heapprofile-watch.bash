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
#
# 2014-03-26
# + initial release
#

set -Ceu

INTERVAL='5'  # in seconds

function printHelp {
cat <<EOF
Usage: ${0##*/} <name>

Calls hp2ps on <name>.hp on file modification but at most every ${INTERVAL}s.
Generates <name>.tmp.hp, <name>.tmp.ps, and <name>.tmp.pdf.
EOF
}

function convertProfile {
	# fix imcomplete profiles
	head -n  \
		"$(grep -n '^END_SAMPLE ' "${1}.hp"  \
			| tail -n 1  \
			| sed 's/^\([[:digit:]]*\)[^[:digit:]].*$/\1/'  \
		)" "${1}.hp" >| "${1}.tmp.hp"  \
	&& hp2ps -e9in -c "${1}.tmp.hp"  \
	&& epstopdf "${1}.tmp.ps"
}

if [ "${#}" -ne 1 ]
then
	printHelp
	exit 1
fi

TIMEFORMAT="%R"

while true
do
	if [ -f "${1}.hp" ]
	then
		echo -n 'rendering ... '
		convertProfile "${1}" || true
		echo -n 'done. Waiting for file modification ... '
		# http://stackoverflow.com/a/858661
		TIME="$(time (inotifywait -e modify "${1}.hp" >/dev/null 2>&1) 2>&1)"
		TIMER="$(bc <<< "x = ${INTERVAL} - ${TIME}; if(x < 0) 0 else x")"
		echo -n "modified after ${TIME}s"
		if [ "${TIMER}" == '0' ]
		then
			echo '.'
		else
			echo ", waiting for additional ${TIMER}s."
			sleep "${TIMER}"
		fi
	else
		echo "${1}.hp does not exist. Retrying in ${INTERVAL}s."
		sleep "${INTERVAL}"
	fi
done
