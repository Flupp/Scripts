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
# Changelog
# 2010-02-09
# * corrected command line parameters of shutdown
#
# 2010-02-02
# * changed if to switch
# + added some working environments
# + added some extra checks
# + added logout and reboot options
#
# 2010-08-14
# * printHelp if no parameters given (instead of shutting down)
#
# 2013-08-21
# * workaround for different qdbus executable names
#

set -e -u -C

function printHelp() {
cat <<EOF
${0##*/} [<option>]
  valid <option>s:
    -l, --logout;
    -r, --reboot;
    -h, -p, -s, --halt, --poweroff, --shutdown;
    --help;
    --license.
  Only one option is accepted.

  This script analyses environment variables to determine the best way to
  logout/reboot/shutdown the current desktop environment safely.
EOF
}

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

if [ "${#}" -ne 1 ]
then
	printHelp
	exit 1
fi

case "${1,,}" in
	(-l | --logout) ACTION=0;;
	(-r | --reboot) ACTION=1;;
	(-h | -p | -s | --halt | --poweroff | --shutdown) ACTION=2;;
	(--license) head -n 31 "${0}" | tail -n +5; exit 0;;
	(--help) printHelp; exit 0;;
	(*) echo "Unknown options: ${@}" >&2; printHelp; exit 1;;
esac

echo "\$DESKTOP_SESSION          == ${DESKTOP_SESSION:-}"
echo "\$GNOME_DESKTOP_SESSION_ID == ${GNOME_DESKTOP_SESSION_ID:-}"
echo "\$KDE_FULL_SESSION         == ${KDE_FULL_SESSION:-}"
echo "\$KDE_SESSION_VERSION      == ${KDE_SESSION_VERSION:-}"

DE="${DESKTOP_SESSION:-}"

# idea from Portland Project
if [ "${KDE_FULL_SESSION:-}" == 'true' ]; then
	if [ "${KDE_SESSION_VERSION:-}" == '4' ]; then
		DE='KDE-4'
	else
		DE='kde-3.5'
	fi
elif [ "${GNOME_DESKTOP_SESSION_ID:-}" != '' ]; then
	DE='gnome'
elif xprop -root _DT_SAVE_MODE | grep ' = \"xfce4\"$' >/dev/null 2>&1; then
	DE='xfce'
fi

case "${DE,,}" in  # ,, converts to lower case
	(kde-3.5) CMDS=('dcop ksmserver ksmserver logout 0 0 -1'           'dcop ksmserver ksmserver logout 0 1 -1'           'dcop ksmserver ksmserver logout 0 2 -1'          );;
	(kde-4  ) CMDS=('qdbus org.kde.ksmserver /KSMServer logout 0 0 -1' 'qdbus org.kde.ksmserver /KSMServer logout 0 1 -1' 'qdbus org.kde.ksmserver /KSMServer logout 0 2 -1');;
	(gnome  ) CMDS=('gnome-session-save --logout'                      'gnome-session-save --shutdown-dialog'             'gnome-session-save --shutdown-dialog'            );;
	(xfce   ) CMDS=('xfce4-session-logout --logout'                    'xfce4-session-logout --reboot'                    'xfce4-session-logout --halt'                     );;
	(*      ) CMDS=(''                                                 'sudo shutdown -r now'                             'sudo shutdown -h -P now'                         ); unset DE;;
	#(enlightenment) CMD='';;
	#(IceWM  ) CMD='';;
esac

echo "${DE:-No desktop environment recognized.}${DE:+ seems to be your current desktop environment.}"
if [ "${CMDS[$ACTION]:-}" == '' ]; then
	echo '(!!) No command known for given action on this desktop environment.' >&2
	exit 1
else
	echo "${CMDS[${ACTION}]}"
	exec ${CMDS[${ACTION}]}
fi

################################################################################

# Example:
# dcop ksmserver default logout 0 -1 -1
#
# First parameter: 	confirm
# 	Obey the user's confirmation setting:	-1
# 	 Don't confirm, shutdown without asking: 0
# 	Always confirm, ask even if the user turned it off: 1
# Second parameter:	type
# 	Select previous action or the default if it's the first time: -1
# 	Only log out: 0
# 	Log out and reboot the machine: 1
# 	Log out and halt the machine: 2
# Third parameter:	mode
# 	Select previous mode or the default if it's the first time: -1
# 	Schedule a shutdown (halt or reboot) for the time all active sessions have exited: 0
# 	Shut down, if no sessions are active. Otherwise do nothing: 1
# 	Force shutdown. Kill any possibly active sessions: 2
# 	Pop up a dialog asking the user what to do if sessions are still active: 3

# $ gnome-session-save --help
#   --logout                Abmelden
#   --force-logout          Abmelden und Unterdrückungen ignorieren
#   --logout-dialog         Abmelden-Dialog anzeigen
#   --shutdown-dialog       Ausschalten-Dialog anzeigen
#   --gui                   Dialogfenster bei Fehlern anzeigen
#   --display=ANZEIGE       X-Anzeige, die verwendet werden soll

# $ xfce4-session-logout --help
#   --logout              Log out without displaying the logout dialog
#   --halt                Halt without displaing the logout dialog
#   --reboot              Reboot without displaying the logout dialog
#   --suspend             Suspend without displaying the logout dialog
#   --hibernate           Hibernate without displaying the logout dialog
#   --fast                Log out quickly; don't save the session
