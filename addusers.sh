#!/bin/bash

input="/home/peter/Scripts/users.txt"

# VARIABLES
first_name=""
last_name=""
user_name=""

# BOOLEANS
append_first=true
append_last=false
append_user=false

# COUNTERS
last_name_count=0
i=1

while IFS= read -r line
do
	com="sudo useradd -m -c '$line, "

	echo "$i: $line"

	for ((j=0; j<${#line}; j++))
	do
		# Stop appending last name to user name,
		# when the last name length is more than 7.
		if [[ $last_name_count -eq 7 ]]
		then
			append_user=false
		fi

		# Do last name.
		if [[ $append_last == true ]]
		then
			to_append=${line:$j:1}
			last_name+=${to_append,,}
		fi

		# Start appending last name to user name.
		if [[ $append_user == true ]]
		then
			to_append=${line:$j:1}
			user_name+=${to_append,,}
			last_name_count=$((last_name_count+1))
		fi

		# Check if we are the first character.
		# If so, append it to users.
		if [[ $j -eq 0 ]]
		then
			to_append=${line:$j:1}
			user_name+=${to_append,,}
		fi

		# Check if we are at the empty space.
		if [[ ${line:$j:1} == " " ]]
		then
			append_first=false
			append_last=true
			append_user=true
		fi

		# Do first name.
                if [[ $append_first == true ]]
                then
                        to_append=${line:$j:1}
                        first_name+=${to_append,,}
                fi
	done

	# Increase counter.
	i=$((i+1))
	# Edit command string.
	com+="$first_name.$last_name@t-systems.com' -e 2021-08-31  $user_name"
	echo $com

	eval $com &&
	# Set password to Start123
	echo "$user_name:Start123" | sudo chpasswd &&

	sudo chage -d 0 $user_name

	# Reset values.
	com=""
	first_name=""
	last_name=""
	user_name=""
	last_name_count=0
	append_first=true
	append_last=false
	append_user=false

done < "$input"
