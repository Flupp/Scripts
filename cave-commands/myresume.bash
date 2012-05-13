#!/bin/bash

exec "${CAVE}" myprintandexec resume --continue-on-failure if-satisfied --resume-file ~/cave.state "${@}"
