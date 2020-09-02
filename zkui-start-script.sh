#!/usr/bin/bash
JAVA_HOME=/home/ebs/soft/jdk
nohup  $JAVA_HOME/bin/java  -jar  /home/ebs/soft/zkui/target/zkui-2.0-SNAPSHOT-jar-with-dependencies.jar  >/dev/null 2>&1 &

