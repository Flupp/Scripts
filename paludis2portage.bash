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
# 2009
# + initial release
#
# 2010-06-13
# * also copy “^[[:space:]]*$”-lines
# * empty directorys produced error
# + added “set -C”
#
# 2010-08-11
# * ExtendedAtomPrefix contained \* by mistake
# * Category used * (accepted empty string) instead of +
#

set -e -u -C

SRC='/etc/paludis/'
DST='/etc/portage/'

function printHelp() {
cat <<EOF
${0##*/} [--src <source-directory>] [--dest <destination-directory>]
  --src <source-directory>, -s <source-directory>
    specifies configuration directory of paludis. Default: ${SRC}
  --dest <destination-directory>, -d <destination-directory>
    specifies a directory where the generated emerge-configuration should be
    stored in. Default: ${DST}

  This script converts paludis keyword, mask, unmask and use files to
  portage/emerge format.
  Portage's/emerge's package.keywords, package.mask, package.unmask and
  package.use must be directories or must not exist.
  The script will overwrite existing files without prompting. Other files will
  be untouched. It deletes and shows all lines which emerge does not understand.
  You have to configure these things manually in portage.
EOF
}

function paludisCat() {
	echo "# This file was created by ${0##*/}"
	case "${1##*.}" in
		(conf) cat "${1}";;
		(bash) bash "${1}";;
		(*   ) cat "${1}" | sed -e "s/^/#/g";;
	esac
}

# man 5 ebuild
# calculate regex one time global, not on every function call
Category='([[:alnum:]_\-]+)'
Package="(${Category})"
AtomBase="(${Category}/${Package})"
AtomVersion='(([[:digit:]]+\.)*[[:digit:]]+[[:alpha:]]?((_alpha|_beta|_pre|_rc|_p)[[:digit:]]+)?)'
AtomPrefixOperator='(>|>=|=|<=|<)'
ExtendedAtomPrefix='(!|!!|~)'
ExtendedAtomPostfix='(\*)'
AtomSlot='(([[:digit:]]+\.)*[[:digit:]]+)'
#AtomUse='(\[\])'  # incomplete, I think
DependAtom="((${AtomBase}|(${AtomPrefixOperator}|${ExtendedAtomPrefix})${AtomBase}-${AtomVersion}${ExtendedAtomPostfix}?)(:${AtomSlot})?)"

CHECKREGEX="^[[:space:]]*(#|${DependAtom}|\$)"

# convert <source> <destination>
function convert() {
	#FILTERCMD="grep -E '^[[:space:]]*[[:alnum:]_\-]*/[[:alnum:]_\-]*[[:space:]#]|^[[:space:]]*#|^[[:space:]]*$'"
	if [ -d "${1}" ]
	then
		for FILE in "${1}"/*
		do
			if [ -e "${FILE}" ]
			then
				if [ ! -d "${FILE}" ]
				then
					convert "${FILE}" "${2}/${FILE##*/}"
				#else  # paludis semms to ignore sub-directories
				#	convert "${FILE}" "${2}"
				fi
			fi
		done
	else
		echo
		if [ ! -e "${2%/*}" ]
		then
			mkdir -p -v "${2%/*}"
		fi
		echo "\"${1}\"  -->  \"${2}\""
		paludisCat "${1}" | grep -E "${CHECKREGEX}" >| "${2}" || true
		paludisCat "${1}" | diff - "${2}" || true
	fi
}

while [ "$#" -gt 0 ]
do
	case "$1" in
		(-s | --src ) shift; SRC="${1?\"--src\" expects one parameter.}"; shift;;
		(-d | --dest) shift; DST="${1?\"--dest\" expects one parameter.}"; shift;;
		(-h | --help) printHelp; exit 0;;
		(-l | --license) head -n 31 "${0}" | tail -n +5; exit 0;;
		(*) printHelp; exit 1;;
	esac
done

SRCARR=(
	keywords.conf
	keywords.bash
	keywords.conf.d
	package_mask.conf
	package_mask.bash
	package_mask.conf.d
	package_unmask.conf
	package_unmask.bash
	package_unmask.conf.d
	use.conf
	use.bash
	use.conf.d
	)
DSTARR=(
	package.keywords/__keywords.conf
	package.keywords/__keywords.bash
	package.keywords
	package.mask/__package_mask.conf
	package.mask/__package_mask.bash
	package.mask
	package.unmask/__package_unmask.conf
	package.unmask/__package_unmask.bash
	package.unmask
	package.use/__use.conf
	package.use/__use.bash
	package.use
	)

for I in $(seq 0 $((${#SRCARR[@]} - 1)))
do
	if [ -e "${SRC}/${SRCARR[I]}" ]
	then
		#if [ -e "${DST}/${DSTARR[I]}" ]
		#then
		#	rm -i -r "${DST}/${DSTARR[I]}"
		#fi
		convert "${SRC}/${SRCARR[I]}" "${DST}/${DSTARR[I]}"
	fi
done
