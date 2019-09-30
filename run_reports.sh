#!/bin/bash

DATE=`date +%m%d%Y`

##########################################################################
# REPORT #1 - ALL GROUPS AND USERS
##########################################################################
echo "Running user report..."
# Grab all group first
##./get_all_groups.rb > 1

# Loop over groups and grab users for each
##for i in `cat 1`
##do
##	./get_group.rb "$i" >> all_users_and_groups_$DATE.txt
##done		

##########################################################################
# REPORT #2 - CONFLUENCE SPACE PERMISSIONS AUDIT
##########################################################################
echo "Running confluence report..."
./get_conf_space_perms.rb |sed -e "s/{}//g" > confluence_space_permissions_$DATE.csv

##########################################################################
# REPORT #3 - JIRA PROJECT PERMISSIONS AUDIT
##########################################################################
echo "Running jira report..."
##./get_jira_project_roles_users.rb > jira_roles_$DATE.csv
