#!/bin/bash
function httpRequest()
{
curl -H "Content-type: application/json" -X POST -d '{"msgtype": "text","text": {"content": "'$message'"}, "at": {"isAtAll":true}}' https://oapi.dingtalk.com/robot/send?access_token=e93a32a37d7077201a16885702875c4613ea985f5ec3a65a64d9b971312cbf5d 
}
message=$1
httpRequest
exit 0
