#! /usr/bin/env bash
 
source /home/$USER/.bashrc

cd /www/_csv

ruby cron.rb > cron.log 2>&1


