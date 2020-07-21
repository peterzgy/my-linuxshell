#/usr/bin/env  bash
#data:2020-7-21
#auther:peterzgy
#desc:生成域名证书;使用：sh  genca.sh www.peterzgy.com
yuming=$1
openssl req  -newkey rsa:4096 \
-nodes -sha256 -keyout ca.key -x509 -days 999999  \
-out ca.crt -subj "/C=CN/L=Hangzhou/O=Harbor/CN=${yuming}"

openssl req -newkey rsa:4096 \
-nodes -sha256 -keyout ${yuming}.key \
-out ${yuming}.csr -subj "/C=CN/L=Hangzhou/O=XXX/CN=${yuming}"

openssl x509 -req -days 999999 -in ${yuming}.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out ${yuming}.crt
