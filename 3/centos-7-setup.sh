#on a fresh centos 7 machine 


sudo tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/$releasever/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF


sudo yum remove docker
sudo yum remove docker-selinux.x86_64


sudo yum install docker-engine

curl -L https://github.com/docker/compose/releases/download/1.6.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose

sudo chkconfig docker on
sudo chkconfig firewalld off


sudo docker run hello-world
