#! /bin/bash

# This shell script is part of the main qtrix script and focuses on the current
# web server active on a machine.

## Begin diagnosing the web server:
echo -e "\n${YELLOW}--- WEB SERVER RELATED ---${ENDCOLOR}"
# Display the latest worker-related messages:
echo -e "${L_BLUE}- Current Apache workers status:${ENDCOLOR}"
apachectl fullstatus | grep "requests currently\|idle workers"

echo -e "\n${L_BLUE}- If there are Apache worker-related messages, they will appear below (latest 10 shown, there could be more):${ENDCOLOR}"
grep 'MaxReq' '/var/log/apache2/error_log' | tail -3

## Check the Apache requests for the past 1 hour:
echo -e "\n${L_BLUE}- The total number of requests within the past 1 hour:${ENDCOLOR}"

# Set some variables like an emtpy total requests variable, and array that's 
# used to collect the requests for each domain below:
total_reqs=0
domain_requests=()
# Create an array of the current domains:
readarray -t domains_list < <(whmapi1 --output=jsonpretty get_domain_info | grep -i \"domain\" | cut -d '"' -f 4)

# Retrieve the reuests for each domain name:
for domain in "${domains_list[@]}"
do
        # Create variables holding the desired times in the Apache log format
        cur_time="$(date "+%d/%h/%Y:%H:%M")"
        past_hour="$(date '+%d/%h/%Y:%H:%M' --date='1 hour ago')"
        
        # Retrieve the number of requests for the desired time for a domain:
        cur_num=$(awk '$4>"['"$past_hour"'" && $4<"['"$cur_time"'"' "/var/log/apache2/domlogs/$domain" "/var/log/apache2/domlogs/$domain-ssl_log" 2>/dev/null | wc -l)
        
        # If the number of requests is 0, then do nothing, else add domain to 
        # The named - domain_requests - array and keep adding to - total_reqs:
        if [[ "$cur_num" == 0 ]]
        then
                continue
        else
                domain_requests+=("$cur_num requests for -- $domain")
                total_reqs=$((total_reqs + cur_num))
        fi
done

# Save IFS and sort the domain requests variable.
CURRENTIFS=$IFS
IFS=$'\n' sorted_domain_requests=("$(sort -n <<<"${domain_requests[*]}")")
IFS=$CURRENTIFS
# Rewrite the array for each new line to be a separate value
readarray -t sorted_domain_requests <<<"${sorted_domain_requests[@]}"

# Output the sorted domains and the total number of requests
for result in "${sorted_domain_requests[@]}"
do
        echo "$result"
done
echo -e "${YELLOW}Total requests: $total_reqs${ENDCOLOR}\n"

# Ask the user to input a number if further review is required of the domains:
read -rp "Type the number of how many domains you'd like to see the IPs for starting from the most requested (0 being none): " input_num

# Retrieve the number of requests for the desired time for a domain:
for (( i=input_num; i > 0; i-- ))
do
        echo -e "\n${YELLOW}The top 8 IPs that performed the most requests for --  ${sorted_domain_requests[-$i]#*-- }${ENDCOLOR}"
        awk '$4>"['"$past_hour"'" && $4<"['"$cur_time"'"' "/var/log/apache2/domlogs/${sorted_domain_requests[-$i]#*-- }" "/var/log/apache2/domlogs/${sorted_domain_requests[-$i]#*-- }-ssl_log" 2>/dev/null | awk '{ print $1 }' | sort | uniq -c | sort -rh | head -n 8
done


