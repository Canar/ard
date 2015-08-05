#!/bin/bash
read -r -e l 
( cat <<< $l ) > out
( tr -d '\n' < out ) > o2
( sed -r 's (&lt;Query&gt;)(.*)(&lt;/Query&gt;) \n\1\2\3\n g' o2 ; echo '' ) | (
	read -r l
	( cat <<< $l ) > head
	read -r l
	( cat <<< $l ) > body
	read -r l
	( cat <<< $l ) > tail
)

recode HTML..UTF-8 body 
xmllint --format body --output b2
vi  b2
xmllint --noblanks b2 --output body
