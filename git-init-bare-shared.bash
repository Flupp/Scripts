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
# 2014-06-27
# + initial release
#

set -Ceu

function ask() {
	case "${2:-}" in
		(y|Y) OPTIONS='[Y/n]'; DEFAULT=0;;
		(n|N) OPTIONS='[y/N]'; DEFAULT=1;;
		(*  ) OPTIONS='[y/n]';;
	esac
	IFS='' read -r -n 1 -p "${1} ${OPTIONS} "
	[ -z "${REPLY}" ] || echo
	case "${REPLY}" in
		(y|Y) return 0;;
		(n|N) return 1;;
		('' ) [ -v DEFAULT ] && return "${DEFAULT}" || ask "${@}";;
		(*  ) ask "${@}";;
	esac
}

echo 'Quick and easy setup of a shared git repository based on file'
echo 'permissions. This is useful, e.g., for sharing via ssh on a server with'
echo 'several logins.'

echo

IFS='' read -r -p 'Name of git directory (without .git extension): ' GITDIR

if ask 'Read permission for everyone?' n
then
	MOD='u=rwX,g=rsX,o=rX'
	MASK='0644'
elif ask 'Read permission for a specific group?' n
then
	MOD='u=rwX,g=rsX,o='
	MASK='0640'
	IFS='' read -r -p 'Name of the group: ' GROUP
else
	MOD='u=rwX,g=,o='
	MASK='false'
fi


echo


mkdir "${GITDIR}.git"
cd    "${GITDIR}.git"
[ -v GROUP ] && chgrp "${GROUP}" .
chmod "${MOD}" .
git --bare init-db --shared="${MASK}"


# kate: default-dictionary en;
