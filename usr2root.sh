su#!/bin/bash
#sudo apt install expect
expect -c "  
spawn su -  
expect \":\"  
send \"super\r\"  
interact  
"

