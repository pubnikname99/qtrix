#! /bin/bash

# This shell script is part of the main qtrix script and focuses on the current
# MySQL database active on a machine.

## Begin diagnosing the web server:
echo -e "\n${YELLOW}--- DATABASE RELATED ---${ENDCOLOR}"
# Display the latest worker-related messages:
echo -e "${L_BLUE}- MySQL version:${ENDCOLOR}"
mysql --version

echo -e "\n${L_BLUE}- Current processlist and number of rows below it::${ENDCOLOR}"
mysqladmin processlist
num_of_rows="$(($(mysqladmin processlist | wc -l) - 4))"
echo -e "${YELLOW} Total rows: $num_of_rows${ENDCOLOR}"

echo -e "\n${L_BLUE}- Users performing slow MySQL queries today (if any):${ENDCOLOR}"
read -r -d '' -a cur_slow_cnf < <( grep slow_query_log /etc/my.cnf | cut -d '=' -f 2 )

if [[ ${cur_slow_cnf[0]} -eq 1 ]]
then
        # Create the variable holding today's date in the MySQL slow query log format
        cur_time="$(date '+%Y-%m-%d')"
        # Retrieve the number of users and the number of slow queries performed:
        grep -a1 $cur_time /var/lib/mysql/mysql_slow.log | grep 'User@Host' | cut -d '[' -f 2 | cut -d ']' -f 1 | sort | uniq -c | sort -rh
else
        echo "${RED}Slow query logging appears to be disabled.${ENDCOLOR}"
fi


