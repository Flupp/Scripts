#!/bin/bash

exec "${CAVE}" myprintandexec resolve --complete --continue-on-failure if-satisfied --keep if-same-metadata --purge '*/*' --resume-file ~/cave.state "${@}"
#    "${CAVE}" myprintandexec resolve -c         -Cs                                -km                     -P      '*/*' --resume-file ~/cave.state "${@}"
