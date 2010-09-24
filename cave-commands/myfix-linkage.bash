#!/bin/bash

exec "${CAVE}" myprintandexec fix-linkage "${@}" -- --continue-on-failure if-independent --resume-file ~/cave.state
