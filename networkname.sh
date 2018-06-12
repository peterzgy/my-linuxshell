var=$(sudo lshw -c network | grep -E 'logical name')
echo ${var:21}
