#!/bin/bash

set -x

exec "${CAVE}" fix-linkage "${@}" -- --continue-on-failure if-satisfied --resume-file ~/cave.state
