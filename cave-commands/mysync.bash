#!/bin/bash

set -e -u -C

"${CAVE}" sync "${@}"

################################################################################

# Source
# http://git.overlays.gentoo.org/gitweb/?p=proj/kde.git;a=tree;f=Documentation/package.keywords;hb=HEAD

cd '/etc/paludis/keywords.conf.d/portage-format'

wget 'http://git.overlays.gentoo.org/gitweb/?p=proj/kde.git;a=blob_plain;f=Documentation/package.keywords/kde-4.4.keywords;hb=HEAD'
rm 'kde-4.4.keywords' || true
mv 'index.html?p=proj%2Fkde.git;a=blob_plain;f=Documentation%2Fpackage.keywords%2Fkde-4.4.keywords;hb=HEAD' 'kde-4.4.keywords'

wget 'http://git.overlays.gentoo.org/gitweb/?p=proj/kde.git;a=blob_plain;f=Documentation/package.keywords/kde-4.5.keywords;hb=HEAD'
rm 'kde-4.5.keywords' || true
mv 'index.html?p=proj%2Fkde.git;a=blob_plain;f=Documentation%2Fpackage.keywords%2Fkde-4.5.keywords;hb=HEAD' 'kde-4.5.keywords'

################################################################################

paludis2portage.bash
