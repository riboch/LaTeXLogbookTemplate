#!/bin/bash
#
#	This script makes the {YEAR}/{MONTH}/{DAY}.tex folder structure for use with 
#	my journal template.
#	
#
#
#
# riboch, 2014-04-24

# High level folder structure
YEARFROM=2017
YEARTO=2020


#Number of days in each month, leaps years handled later.
DAYSINMONTH=(31 28 31 30 31 30 31 31 30 31 30 31)

#Yearly includes file
LOOKHEREFORINC=LOOKATME.txt
echo '' > $LOOKHEREFORINC

for a1 in $( seq $YEARFROM $YEARTO );
do
	#Make year directory, check to make sure you did not do something stupid.
	YEARFILE=$a1/$a1.tex

	if [ ! -d "$a1" ];
	then 
		printf "Making directory %s.\n" $a1
		mkdir $a1
		
		#Make yearly file, populate with part
		printf "\\part{%s}\n" $a1 > $YEARFILE

		#Include file for the main latex file.
		printf "%%\include{%s/%s}\n" $a1 $a1 >> $LOOKHEREFORINC
	else
		printf "Directory %s already exists, bailing.\n" $a1
		exit 
	fi

	for a2 in $( seq 12 );
	do 
		#Need zero padding for month number
		MONTHSTRING=$(printf "%02d" $a2)
		#Make month directory, check to make sure you did not do something really stupid.
		if [ ! -d "$a1/$MONTHSTRING" ];
		then 
			printf "Making directory %s/%s.\n" $a1 $MONTHSTRING
			mkdir $a1/$MONTHSTRING

			printf "\t%%\\chapter{%s}\n" $(date -d "$(printf "%s%s01" $a1 $MONTHSTRING)" +%B) >> $YEARFILE
		else
			printf "Directory %s/%s already exists, bailing.\n" $a1 $(printf "%02d" $MONTHSTRING)
			exit 
		fi
		
		#Write files
		for a3 in $( seq ${DAYSINMONTH[$(( $a2-1 ))]} );
		do
			DATEFILE=$a1/$MONTHSTRING/$(printf "%d%s%02d.tex" $a1 $MONTHSTRING $a3)

			printf "\t\t%%\input{%d/%s/%d%s%02d}\n" $a1 $MONTHSTRING $a1 $MONTHSTRING $a3 >> $YEARFILE

			printf "\\section{%s, %d-%s-%02d}\n" $(date -d "$(printf "%d-%s-%02d" $a1 $MONTHSTRING $a3)" +%A) $a1 $MONTHSTRING $a3  > $DATEFILE
			printf "\\label{%d%d%02d:S}\n" $a1 $a2 $a3  >> $DATEFILE
		done

		#Write files: Leap year
		if [ $(( $a1 % 4)) -eq 0 ] && [ $a2 -eq 2 ];
		then 
			printf "\\section{%s, %d-02-29}\n" $(date -d "$(printf "%d-02-29" $a1)" +%A) $a1  > $a1/$MONTHSTRING/$(printf "%d0229.tex" $a1)
			printf "\\label{%d0229:S}\n" $a1 >> $a1/02/$(printf "%d0229.tex" $a1)
		fi

	done

done
