#!/bin/bash

declare -i I=0

for A in "${0}" "${@}"
do
	echo "Parameter ${I}: ${A}"
	I+=1
done
