#!/bin/bash

exec "${CAVE}" myprintandexec fix-linkage "${@}" -- --continue-on-failure if-satisfied --resume-file ~/cave.state
