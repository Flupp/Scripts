#!/bin/bash

exec "${CAVE}" myprintandexec resume --continue-on-failure if-independent --resume-file ~/cave.state "${@}"
