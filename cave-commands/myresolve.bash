#!/bin/bash

set -x

exec "${CAVE}" resolve --complete --continue-on-failure if-satisfied --keep if-same-metadata --purge '*/*' --resume-file ~/cave.state "${@}"
#    "${CAVE}" resolve -c         -Cs                                -km                     -P      '*/*' --resume-file ~/cave.state "${@}"
