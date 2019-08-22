#!/bin/bash
#
# 2019.08.17 v1.0 (the base one)
# 2019.08.22 v1.5 (add pipeline as code)
# by wilmos

## env config
sudo su - root -c "/bin/echo  '/usr/bin/echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables' >> /etc/rc.local"
sudo iptables -t nat -A PREROUTING -d 10.1.0.165 -j DNAT --to-destination 10.0.2.15
sudo su - root -c "/bin/echo '/sbin/iptables -t nat -A PREROUTING -d 10.1.0.165 -j DNAT --to-destination 10.0.2.15' >> /etc/rc.local"
## sudo su - root -c "/bin/echo '/usr/local/bin/minikube start --registry-mirror=https://registry.docker-cn.com --vm-driver=none' >> /etc/rc.local"
sudo /sbin/setenforce 0
sudo su - root -c "/bin/sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config"
cd /tmp/package


## install base package 
#sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
#sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
#sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
#sudo yum-config-manager --enable docker-ce-nightly
#sudo yum-config-manager --enable docker-ce-test
sudo su - root -c "cd /tmp/package && /bin/cp jenkins.repo  docker-ce.repo /etc/yum.repos.d/"
sudo yum install -y java-1.8.0-openjdk.x86_64
sudo yum install -y zip unzip git net-tools vim curl


## install jenkins
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
# sudo yum install -y jenkins
sudo yum install -y jenkins-2.176.2-1.1.noarch.rpm
sudo su - root -c "/etc/init.d/jenkins stop"
sudo su - root -c "rm -rf /var/lib/jenkins"
sudo su - root -c "unzip /tmp/package/jenkins.zip -d /var/lib/"
sudo su - root -c "chown -R jenkins.jenkins /var/lib/jenkins"
sudo su - root -c "rm -rf /var/lib/jenkins/jobs/*/{lastSuccessful,lastStable}"
sudo su - root -c "/sbin/chkconfig jenkins on"
sudo su - root -c "/etc/init.d/jenkins start"
sudo su - root -c "/etc/init.d/jenkins status"

## install docker
sudo yum -y remove docker \
             docker-client \
             docker-client-latest \
             docker-common \
             docker-latest \
             docker-latest-logrotate \
             docker-logrotate \
             docker-engine
sudo yum install -y yum-utils \
     device-mapper-persistent-data \
     lvm2

#sudo yum install -y docker-ce \
#       docker-ce-cli \
#       containerd.io

sudo yum install -y docker-ce-19.03.1-3.el7.x86_64.rpm \
       docker-ce-cli-19.03.1-3.el7.x86_64.rpm \
       containerd.io-1.2.6-3.3.el7.x86_64.rpm
sudo systemctl enable docker
sudo systemctl start docker
sudo systemctl status docker
sudo docker run hello-world
sudo su - root -c  "curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://f1361db2.m.daocloud.io"
sudo systemctl stop docker
sudo systemctl start docker
sudo systemctl status docker
sudo su - root -c "/bin/echo '%jenkins ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/jenkins"
sudo su - root -c "chmod 660 /etc/sudoers.d/jenkins"


## install minikube and kubectl 
sudo cp kubectl /usr/local/bin/kubectl
sudo chmod +x /usr/local/bin/kubectl
#sudo cp minikube /usr/local/bin/minikube
#sudo chmod +x /usr/local/bin/minikube
sudo curl -Lo minikube http://kubernetes.oss-cn-hangzhou.aliyuncs.com/minikube/releases/v1.2.0/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/


## lunch k8s cluster
sudo su - root -c "swapoff -a"
sudo su - root -c "/usr/bin/echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables"
sudo su - root -c "minikube start --registry-mirror=https://registry.docker-cn.com --vm-driver=none"
sudo su - root -c "minikube addons enable heapster"

## pull basic image
sudo su - root -c "docker pull daocloud.io/library/node:6.14.2"
sudo su - root -c "docker pull daocloud.io/library/nginx"
sudo su - root -c "docker pull gogs/gogs"


## init app env
/bin/cat >server.js <<EOF
var http = require('http');

var handleRequest = function(request, response) {
  console.log('Received request for URL: ' + request.url);
  response.writeHead(200);
  response.write("INIT");
  response.write(" | ");
  response.write(process.env.HOSTNAME);
  response.end(": Hello World!  |v1| \n");
};
var www = http.createServer(handleRequest);
www.listen(8080);
EOF
/bin/cat >Dockerfile <<EOF
FROM daocloud.io/library/node:6.14.2
EXPOSE 8080
ENV ENV_TAG INIT
COPY server.js .
CMD node server.js
EOF
sudo /bin/docker build -t registry.cn-hangzhou.aliyuncs.com/wilmos/nodejs:INIT_v1 .
sudo su - root -c "kubectl create deployment nodejs --image=registry.cn-hangzhou.aliyuncs.com/wilmos/nodejs:INIT_v1 && kubectl expose deployment nodejs  --type=NodePort --port=8080 "
sudo su - root -c "kubectl create deployment nodejs-stag --image=registry.cn-hangzhou.aliyuncs.com/wilmos/nodejs:INIT_v1 && kubectl expose deployment nodejs-stag  --type=NodePort --port=8080 "
sudo su - root -c "kubectl create deployment nodejs-prod --image=registry.cn-hangzhou.aliyuncs.com/wilmos/nodejs:INIT_v1 && kubectl expose deployment nodejs-prod  --type=NodePort --port=8080 "
echo "nodejs dev/test env:"
sudo su - root -c "minikube service nodejs --url   | sed 's/10.0.2.15/10.1.0.165/' "
echo "nodejs stage env:"
sudo su - root -c "minikube service nodejs-stag --url   | sed 's/10.0.2.15/10.1.0.165/' "
echo "nodejs prod env:"
sudo su - root -c "minikube service nodejs-prod --url   | sed 's/10.0.2.15/10.1.0.165/' "

echo INIT > env.txt
/bin/cat >Dockerfile <<EOF
FROM daocloud.io/library/nginx
COPY env.txt /usr/share/nginx/html/
EOF
sudo /bin/docker build -t registry.cn-hangzhou.aliyuncs.com/wilmos/nginx:INIT_v1 .
sudo su - root -c "kubectl create deployment nginx --image=registry.cn-hangzhou.aliyuncs.com/wilmos/nginx:INIT_v1 && kubectl expose deployment nginx  --type=NodePort --port=80 "
sudo su - root -c "kubectl create deployment nginx-stag --image=registry.cn-hangzhou.aliyuncs.com/wilmos/nginx:INIT_v1 && kubectl expose deployment nginx-stag  --type=NodePort --port=80 "
sudo su - root -c "kubectl create deployment nginx-prod --image=registry.cn-hangzhou.aliyuncs.com/wilmos/nginx:INIT_v1 && kubectl expose deployment nginx-prod  --type=NodePort --port=80 "
echo "nginx dev/test env:"
sudo su - root -c "minikube service nginx --url   | sed 's/10.0.2.15/10.1.0.165/' " | sed 's/$/\/env.txt/'
echo "nginx stage env:"
sudo su - root -c "minikube service nginx-stag --url   | sed 's/10.0.2.15/10.1.0.165/' " | sed 's/$/\/env.txt/'
echo "nginx prod env:"
sudo su - root -c "minikube service nginx-prod --url   | sed 's/10.0.2.15/10.1.0.165/' " | sed 's/$/\/env.txt/'


## init git env
sudo su - root -c "rm -rf  /var/lib/gogs"
sudo su - root -c "unzip /tmp/package/gogs.zip -d /var/lib/"
sudo su - root -c "chown -R vagrant.vagrant /var/lib/gogs"
sudo su - root -c "chown -R root.root /var/lib/gogs/ssh/*"
sudo su - root -c "docker run -d --name=gogs -p 10022:22 -p 10080:3000 -v /var/lib/gogs:/data gogs/gogs"
echo "env init finished!"
