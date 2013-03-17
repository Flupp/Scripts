#!/bin/bash

set -e -u -C

"${CAVE}" sync "${@}"

################################################################################

# Source
# http://git.overlays.gentoo.org/gitweb/?p=proj/kde.git;a=tree;f=Documentation/package.keywords;hb=HEAD

cd '/etc/paludis/keywords.conf.d/portage-format'

#wget 'http://git.overlays.gentoo.org/gitweb/?p=proj/kde.git;a=blob_plain;f=Documentation/package.keywords/kde-4.4.keywords;hb=HEAD'
#rm 'kde-4.4.keywords' || true
#mv 'index.html?p=proj%2Fkde.git;a=blob_plain;f=Documentation%2Fpackage.keywords%2Fkde-4.4.keywords;hb=HEAD' 'kde-4.4.keywords'

#wget 'http://git.overlays.gentoo.org/gitweb/?p=proj/kde.git;a=blob_plain;f=Documentation/package.keywords/kde-4.5.keywords;hb=HEAD'
#rm 'kde-4.5.keywords' || true
#mv 'index.html?p=proj%2Fkde.git;a=blob_plain;f=Documentation%2Fpackage.keywords%2Fkde-4.5.keywords;hb=HEAD' 'kde-4.5.keywords'

#wget 'http://git.overlays.gentoo.org/gitweb/?p=proj/kde.git;a=blob_plain;f=Documentation/package.keywords/kde-4.6.keywords'
#rm 'kde-4.6.keywords' || true
#mv 'index.html?p=proj%2Fkde.git;a=blob_plain;f=Documentation%2Fpackage.keywords%2Fkde-4.6.keywords' 'kde-4.6.keywords'

#wget 'http://git.overlays.gentoo.org/gitweb/?p=proj/kde.git;a=blob_plain;f=sets/kdepim-4.6'
#rm 'kde-pim-4.6.keywords' || true
#mv 'index.html?p=proj%2Fkde.git;a=blob_plain;f=sets%2Fkdepim-4.6' 'kde-pim-4.6.keywords'

#wget 'http://git.overlays.gentoo.org/gitweb/?p=proj/kde.git;a=blob_plain;f=Documentation/package.keywords/kde-4.7.keywords'
#rm 'kde-4.7.keywords' || true
#mv 'index.html?p=proj%2Fkde.git;a=blob_plain;f=Documentation%2Fpackage.keywords%2Fkde-4.7.keywords' 'kde-4.7.keywords'

wget 'http://git.overlays.gentoo.org/gitweb/?p=proj/kde.git;a=blob_plain;f=Documentation/package.keywords/kde-4.8.keywords'
rm 'kde-4.8.keywords' || true
mv 'index.html?p=proj%2Fkde.git;a=blob_plain;f=Documentation%2Fpackage.keywords%2Fkde-4.8.keywords' 'kde-4.8.keywords'


################################################################################

"${0%/*}"/../paludis2portage.bash
