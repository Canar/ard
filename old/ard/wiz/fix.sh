#!/bin/bash
tmp=$(tempfile)
pad(){
	printf "%$(( $(echo "$1" | wc -c ) + $3 ))s" "$1 $2." | tr -d '\n'
}
approximate(){ #input,uncertainty
	zeroes=$(( $( echo $2 | wc -c ) - 2))
	head -c $zeroes </dev/zero >$tmp
	strd=$( cat $tmp | tr '\0' '.' )
	strz=$( cat $tmp | tr '\0' '0' )
	echo $1 | sed "s/^\(.*\)$strd/\1$strz/"
}
timeto(){
	local rn del hr min sec
	rn=$( date +%s )
	del=$(( $1 - $rn ))
	if [[ $del -lt 60 ]] ; then 
		echo "${del}s"
		exit
	fi
	min=$(( $del / 60 ))
	if [[ $min -lt 60 ]] ; then 
		sec=$(( $del % 60 ))
		echo "${min}m${sec}s"
		exit
	fi
	hr=$(( $min / 60 ))
	if [[ $hr -lt 24 ]] ; then 
		sec=$(( $del % 60 ))
		min=$(( $del % 3600 / 60 ))
		echo "${hr}h${min}m${sec}s"
		exit
	fi
}
getcurrsect(){
	smartctl -a /dev/sdd |\
		grep -A1 CURRENT_TEST_STATUS |\
		tail -1 >s
	re='s/^.*(\([0-9]\+\)-\([0-9]\+\))$/\' 
	sectmin="$(sed "${re}1/" s)"
	if [[ -z $sect0 ]] ; then 
		sect0=$sectmin
		begin=$( date '+%s' )
	fi
	sectmax="$(sed "${re}2/" s)"
	sectdif=$(( $sectmax - $sectmin ))
	sect=$(( ( $sectmin + $sectmax ) / 2))
}

# 1  Selective offline   Self-test routine in progress 90%     26515         -
final=3907029168 
update=60
begin=$( date '+%s' )
getcurrsect
#curr=$(( $( cat last | tr -d '\n' ) + 1 ))
curr=$sect
while [ "$curr" -le "$final" ] ; do
	inc=1
	echo -n "Testing from $curr to $final."
#	smartctl -t select,$curr-3907029168 /dev/sdd >> log 
	smartctl -l selftest /dev/sdd >result
	dots=0
	unset ls
	while grep -q '^# 1.*Self-test routine in progress ' result ; do
		if [[ $inc -le $update ]] ; then
			echo -n "."
			dots=$(( $dots + 1 ))
			sleep $inc
			inc=$(( $inc + ( $inc / 4 + 1 ) ))
			if [[ $inc -gt $update ]] ; then echo ; fi
		else
			getcurrsect
			now=$( date '+%s' )
#			echo -n "Current sector: ~$( approximate $sect $sectdif )"
			echo -n "Current sector: ~$sect"
			if [[ -n $ls ]] ; then 
				sectwork=$(( $sect - $ls ))
				per=$(( $sectwork * 60 / $update )) 
#				echo -n ", ~$( approximate $per $sectdif ) sectors/min"
				echo -n ", ~$per sectors/min"
				ieta=$(( $now + ( $final - $sect ) * $update / $sectwork ))
				echo -n ", interval ETA: $( timeto $ieta )"
				jeta=$(( $begin + ( $final - $sect0 ) * ( $now - $begin ) / ( $sect - $sect0 ) ))
				echo -n ", job ETA: $( timeto $jeta )"
			fi
			echo .
			ls=$sect
			sleep $update
		fi
		smartctl -l selftest /dev/sdd >result
	done
	cat result |\
		tee -a log |\
		grep -E '^# 1 ' |\
		sed 's/\W\+/ /g ; s/^.* \(\w\+\)/\1/g' >>bbs
	delta=$( ( tail -2 bbs | sort -r |tr '\n' ' ' ; echo " - p" ) | dc -f - | tr -d '\n' )
	pad "Increased by" $delta $(( 16 - $dots ))
	prb=$( tail -1 bbs )
	pad "Failure at" $prb 12
	echo
	curr=$(( $( tail -1 bbs | tr -d '\n' ) + 1 ))
	smartctl -t select,$curr-3907029168 /dev/sdd >> log 
done
