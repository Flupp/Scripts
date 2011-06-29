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
# Changelog
# 2010-05-24
# + initial version
#
# 2010-08-14
# * extended help
#
# 2011-06-29
# * fixed filtering
#

# see man 5 vdr

set -u -C

if [ "${#}" -ne 1 ]
then
	echo "${0##*/} <filename>"
	echo '  Prints the channels from a vdr channel config to stdout in four groups:'
	echo '    TV (free), Radio (free), TV (encrypted), Radio (encrypted)'
	echo '  The output can be used as a new vdr channel config.'
	exit
fi

# echo ':TV (free)'
# grep -e '^[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:\([^:01][^:]*\|[01][^:]\+\):[^:]*:[^:]*:0:[^:]*:[^:]*:[^:]*:[^:]*' "${1}"
# 
# echo ':Radio (free)'
# grep -e '^[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:0:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*' "${1}"
# 
# echo ':TV (encrypted)'
# grep -e '^[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:\([^:01][^:]*\|[01][^:]\+\):[^:]*:[^:]*:\([^:0][^:]*\|[0][^:]\+\):[^:]*:[^:]*:[^:]*:[^:]*' "${1}"
# 
# echo ':Radio (encrypted)'
# grep -e '^[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:1:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*' "${1}"

declare -r a='[^:]*'
declare -r not0='([^:01][^:]*|[01][^:]+)'

echo ':TV (free)'
grep -E "^$a:$a:$a:$a:$a:$not0:$not0:$a:0:$a:$a:$a:$a" "${1}"

echo ':Radio (free)'
grep -E "^$a:$a:$a:$a:$a:0:$not0:$a:0:$a:$a:$a:$a" "${1}"

echo ':TV (encrypted)'
grep -E "^$a:$a:$a:$a:$a:$not0:$not0:$a:$not0:$a:$a:$a:$a" "${1}"

echo ':Radio (encrypted)'
grep -E "^$a:$a:$a:$a:$a:0:$not0:$a:$not0:$a:$a:$a:$a" "${1}"

echo ':Only Video (free)'
grep -E "^$a:$a:$a:$a:$a:$not0:0:$a:0:$a:$a:$a:$a" "${1}"

echo ':Only Video (encrypted)'
grep -E "^$a:$a:$a:$a:$a:$not0:0:$a:$not0:$a:$a:$a:$a" "${1}"

echo ':Other (free)'
grep -E "^$a:$a:$a:$a:$a:0:0:$a:0:$a:$a:$a:$a" "${1}"

echo ':Other (encrypted)'
grep -E "^$a:$a:$a:$a:$a:0:0:$a:$not0:$a:$a:$a:$a" "${1}"
