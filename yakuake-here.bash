#!/bin/bash

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# Copyright (c) 2013, Toni Dietze
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
# 2013-06-22
# + initial release
#
# 2013-08-21
# * workaround for different qdbus executable names
#

#
# Open a new tab in yakuake in the current directory.
#

set -Ceu

function find_qdbus {
	local -ar QDBUS_CMDS=(qdbus qdbus-qt5 qdbus-qt4)
	for QDBUS in "${QDBUS_CMDS[@]}"
	do
		command -v "${QDBUS}" >/dev/null 2>&1 && return
	done
	unset QDBUS
	echo "None of the folowing commands found: ${QDBUS_CMDS[*]}" >&2
	return 1
}

find_qdbus || exit 1

function qdbus {
	command "${QDBUS}" "${@}"
}

{
	qdbus org.kde.yakuake /yakuake/sessions addSession || yakuake
	qdbus org.kde.yakuake /yakuake/sessions runCommand "cd $(printf '%q' "${PWD}")"
	# qdbus org.kde.yakuake /yakuake/tabs setTabTitle "`qdbus org.kde.yakuake /yakuake/sessions activeSessionId`" "$(echo %aPath% | sed -e 's|.*/\([^/]*\)/$|\1|')"
	if [ "$(qdbus org.kde.yakuake /yakuake/MainWindow_1 org.qtproject.Qt.QWidget.visible)" == "false" ]
	then qdbus org.kde.yakuake /yakuake/window toggleWindowState
	fi
} &>/dev/null
