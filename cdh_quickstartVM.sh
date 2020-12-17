#########################################################################
# File Name: cdh_quickstartVM.sh
# Author: zouguoyin
# mail: 995637339@qq.com
# Created Time: 2020年12月16日 星期三 16时13分11秒
#########################################################################
#!/bin/bash
docker run \
--name cdh \
--hostname=quickstart.cloudera  \
--privileged=true  \
-t -i -p 8020:8020 -p 8022:8022 -p 7180:7180 -p 21050:21050 -p 50070:50070 -p 50075:50075 -p 50010:50010 -p 50020:50020 -p 8890:8890 -p 60010:60010 -p 10002:10002 -p 25010:25010 -p 25020:25020 -p 18088:18088 -p 8088:8088 -p 19888:19888 -p 7187:7187 -p 11000:11000 \
cloudera/quickstart /bin/bash -c '/usr/bin/docker-quickstart && /home/cloudera/cloudera-manager --express && service ntpd start'
