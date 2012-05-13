#!/bin/bash

set -x

exec "${CAVE}" resume --continue-on-failure if-satisfied --resume-file ~/cave.state "${@}"
