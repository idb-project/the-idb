#!/bin/bash 

DIRS_TO_REMOVE=(config/brille config/btm-dev config/btm-prod config/deploy .idea idb.iml doc)

for i in "${DIRS_TO_REMOVE[@]}"
do
	rm -rf $i
done

mv config config.sample

