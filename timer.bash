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
# 2010-06-23
# + initial release
#
# 2010-08-14
# * reworked help
#

set -e -u -C

if [ "${#@}" -lt 1 ]
then
cat <<EOF
${0##*/} <time>
  This script sleeps until the specified time.
  <time> must adhere to the syntax of date.

  Examples:
    ${0##*/} 23:59 && echo -e '\aWake up! A new day begins in a minute.'
    ${0##*/} 2101-01-01 00:00 && echo 'Happy new century!'
EOF
exit 1
fi

declare -i UNTIL="$(date -d "${*}" +'%s')"
declare -i NOW="$(date +'%s')"
declare -i DIFF="$((${UNTIL} - ${NOW}))"

#echo "${UNTIL} - ${NOW} = ${DIFF}"

if [ "${DIFF}" -lt 0 ]
then
	echo 'Specified time is in the past or input format is invalid.' >&2
	exit 1
fi

declare -i D H M S
S="DIFF"
M="S / 60"
H="M / 60"
D="H / 24"
S="S % 60"
M="M % 60"
H="H % 24"

[ "${S}" -gt 0 ] && SS="${S}s " || SS=''
[ "${M}" -gt 0 ] && MM="${M}m " || MM=''
[ "${H}" -gt 0 ] && HH="${H}h " || HH=''
[ "${D}" -gt 0 ] && DD="${D}d " || DD=''

echo -n "Sleeping for ${DD}${HH}${MM}${SS}... "
sleep "${DIFF}s"
echo 'done.'
