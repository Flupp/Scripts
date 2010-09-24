#!/bin/bash

printf "%q" "${CAVE}"
for A in "${@}"
do
	printf " %q" "${A}"
done

echo

exec "${CAVE}" "${@}"
