#!/bin/bash

exec "${CAVE}" myprintandexec resolve --complete --continue-on-failure if-independent --purge '*/*' --resume-file ~/cave.state "${@}"
#    "${CAVE}" myprintandexec resolve -c         -Ci                                  -P      '*/*' --resume-file ~/cave.state "${@}"
