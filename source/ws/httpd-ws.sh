echo -e "\n${YELLOW}--- WEB SERVER RELATED ---${ENDCOLOR}
${L_BLUE}- If there are Apache worker-related messages, they will appear below (latest 10 shown, there could be more):${ENDCOLOR}"
grep 'MaxReq' '/var/log/apache2/error_log' | tail -3

echo -e "${L_BLUE}- The total number of requests within the past 1 hour:${ENDCOLOR}"
###

