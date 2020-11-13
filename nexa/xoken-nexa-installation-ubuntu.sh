#!/bin/bash
if [ $# -ne 1 ]; then
    echo $0: usage: $0 [New Neo4j password]
    exit 1
fi
neo4jpassword=$1
sudo apt-get update -y
sudo apt-get install openjdk-8 -y
sudo apt-get install wget -y
sudo apt-get install tar -y
sudo apt-get install curl -y
sudo apt-get install openssl -y
sudo apt-get install unzip -y
sudo chown -R $USER:$USER /opt
cd /opt
#
#
# Downloading and extracting cassandra-3.11.6
#
#
echo "Downloading and extracting cassandra-3.11.6"
wget -c https://archive.apache.org/dist/cassandra/3.11.6/apache-cassandra-3.11.6-bin.tar.gz
tar -xvzf apache-cassandra-3.11.6-bin.tar.gz
################################################
#
#
# Updating cassandra.yaml
#
#
echo "Updating cassandra.yaml"
cassandraconfig=apache-cassandra-3.11.6/conf/cassandra.yaml
grep -q '^listen\_address.*' $cassandraconfig && sed -i "s/listen_address:.*/listen_address: localhost/" $cassandraconfig || echo "listen_address: localhost" >> $cassandraconfig
grep -q '^concurrent\_reads.*' $cassandraconfig && sed -i "s/concurrent_reads:.*/concurrent_reads: 32/" $cassandraconfig || echo 'concurrent_reads: 32' >> $cassandraconfig
grep -q '^concurrent\_writes.*' $cassandraconfig && sed -i "s/concurrent_writes:.*/concurrent_writes: 96/" $cassandraconfig || echo 'concurrent_writes: 96' >> $cassandraconfig
grep -q '^concurrent\_counter\_writes.*' $cassandraconfig && sed -i "s/concurrent_counter_writes:.*/concurrent_counter_writes: 32/" $cassandraconfig || echo 'concurrent_counter_writes: 32' >> $cassandraconfig
grep -q '^native\_transport\_max\_threads.*' $cassandraconfig && sed -i "s/native_transport_max_threads:.*/native_transport_max_threads: 256/" $cassandraconfig || echo 'native_transport_max_threads: 256' >> $cassandraconfig
#################################################
#
#
# Updating limits.conf
#
#
echo "Updating limits.conf"
limits=/etc/security/limits.conf
sudo grep -q '^\*\ \-\ memlock.*' $limits && sudo sed -i "s/\*\ \-\ memlock.*/* - memlock unlimited/" $limits || sudo sh -c "echo '* - memlock unlimited' >> $limits"
sudo grep -q '^\*\ \-\ nofile.*' $limits && sudo sed -i "s/\*\ \-\ memlock.*/* - nofile 100000/" $limits || sudo sh -c "echo '* - nofile 100000' >> $limits"
sudo grep -q '^\*\ \-\ nproc.*' $limits && sudo sed -i "s/\*\ \-\ memlock.*/* - nproc 32768/" $limits || sudo sh -c "echo '* - nproc 32768' >> $limits"
sudo grep -q '^\*\ \-\ as.*' $limits && sudo sed -i "s/\*\ \-\ memlock.*/* - as unlimited/" $limits || sudo sh -c "echo '* - as unlimited' >> $limits"
##################################################
#
#
# Updating sysctl.conf
#
#
echo "Updating sysctl.conf"
sysctl=/etc/sysctl.conf
sudo grep -q '^vm\.max\_map\_count.*' $sysctl && sudo sed -i "s/\* \- memlock.*/vm.max_map_count = 1048575 /" $sysctl || sudo echo 'vm.max_map_count = 1048575' >> $sysctl
##################################################
#
#
# Setting the PATH environment variable for cassandra in your .bashrc file
#
#
echo "Setting the PATH environment variable for cassandra in your .bashrc file"
echo "export PATH=$PATH:/opt/apache-cassandra-3.11.6/bin" >> ~/.bashrc
##################################################
#
#
# Starting cassandra in a new terminal window
#
#
echo "Starting cassandra in a new terminal window"
gnome-terminal --title=newWindow -- bash -c "/opt/apache-cassandra-3.11.6/bin/cassandra; bash"
##################################################
#
#
# Downloading and extracting neo4j-community-3.5.20
#
#
echo "Downloading and extracting neo4j-community-3.5.20"
wget -c "https://neo4j.com/artifact.php?name=neo4j-community-3.5.20-unix.tar.gz" -O "neo4j-community-3.5.20-unix.tar.gz"
tar -xvzf neo4j-community-3.5.20-unix.tar.gz
##################################################
#
#
# Updating neo4j.conf
#
#
echo "Updating neo4j.conf"
neo4jconfig=neo4j-community-3.5.20/conf/neo4j.conf
echo 'dbms.connector.bolt.thread_pool_min_size=20' >> $neo4jconfig
echo 'dbms.connector.bolt.thread_pool_max_size=2048' >> $neo4jconfig
echo 'dbms.connector.bolt.thread_pool_keep_alive=5m' >> $neo4jconfig
#
# NOTE: uncommenting the below line might cause problems while starting neo4j
#
#grep -q '^dbms.connector.default_listen_address.*' $neo4jconfig && sed -i "s/dbms.connector.default_listen_address.*/dbms.connector.default_listen_address=0.0.0.0 /" $neo4jconfig || echo 'dbms.connector.default_listen_address=0.0.0.0' >> $neo4jconfig
##################################################
#
#
# Setting the PATH environment variable for neo4j in your .bashrc file
#
#
echo "Setting the PATH environment variable for neo4j in your .bashrc file"
echo "export PATH=$PATH:/opt/apache-cassandra-3.11.6/bin:/opt/neo4j-community-3.5.20/bin" >> ~/.bashrc
##################################################
#
#
# Starting neo4j
#
#
echo "Starting neo4j"
(cd /opt/neo4j-community-3.5.20/bin ; ./neo4j start )
##################################################
#
#
# Installing required packages libsecp256k1-0 and libleveldb-dev 
#
#
echo "Installing required package libsecp256k1-0"
sudo apt-get install libsecp256k1-0 -y
echo "Installing required package libleveldb-dev"
sudo apt-get install libleveldb-dev -y
##################################################
#
#
# Creating a softlink for libleveldb in /usr/lib/
#
#
echo "Creating a softlink for libleveldb in /usr/lib/"
sudo ln  -s /usr/lib/x86_64-linux-gnu/libleveldb.so.1.22.0 /usr/lib/libleveldb.so.1
##################################################
#
#
# Checking Ubuntu OS version and downloading appropriate Xoken Nexa release
#
#
echo "Checking Ubuntu OS version and downloading appropriate Xoken Nexa release"
cat /etc/*release >> osversion.txt
grep -q "^DISTRIB\_RELEASE\=20\.04" osversion.txt 
if [ $? -eq 0 ]
then
nexa=xoken-nexa_release-1.1.2_ubuntu2004.zip
wget -c https://www.xoken.org/download/xoken-nexa/6185/xoken-nexa_release-1.1.2_ubuntu2004.zip
else
nexa=xoken-nexa_release-1.1.2_ubuntu1804.zip
wget -c https://www.xoken.org/download/xoken-nexa/6184/xoken-nexa_release-1.1.2_ubuntu1804.zip
fi
#################################################
#
#
# Creating directory 'xoken' under /opt/ and unzipping Xoken Nexa in /opt/xoken
#
#
echo "Creating directory 'xoken' under /opt/ and unzipping Xoken Nexa in /opt/xoken"
mkdir /opt/xoken
unzip $nexa -d /opt/xoken
#################################################
#
#
# Waiting for Neo4j to start
#
#

(cd /opt/neo4j-community-3.5.20/bin ; ./neo4j status ) >> neo4jstatus.txt
while true ; do
	grep -q "^Neo4j\ is\ running.*" neo4jstatus.txt
	if [ $? -eq 0 ]
	then
	break
	else
	sleep 3
	echo "waiting for Neo4j to start..."
	(cd /opt/neo4j-community-3.5.20/bin ; ./neo4j status ) >> neo4jstatus.txt
	fi
done
rm neo4jstatus.txt
#################################################
#
#
# Creating new Neo4j password
#
#
echo "Creating new Neo4j password"
curl -H "Content-Type: application/json" -X POST -d '{"password":"$neo4jpassword"}' -u neo4j:neo4j http://localhost:7474/user/neo4j/password
#################################################
#
#
# Applying constraints (in Neo4j)
#
#
echo "Applying constraints (in Neo4j)"
curl -X POST -H 'Content-type: application/json' http://neo4j:$neo4jpassword@localhost:7474/db/data/transaction/commit -d '{"statements": [{"statement": "CREATE CONSTRAINT ON (n:mnode) ASSERT n.v IS UNIQUE;"}]}'
curl -X POST -H 'Content-type: application/json' http://neo4j:$neo4jpassword@localhost:7474/db/data/transaction/commit -d '{"statements": [{"statement": "CREATE CONSTRAINT ON ( namestate:namestate ) ASSERT namestate.name IS UNIQUE;"}]}'
curl -X POST -H 'Content-type: application/json' http://neo4j:$neo4jpassword@localhost:7474/db/data/transaction/commit -d '{"statements": [{"statement": "CREATE CONSTRAINT ON ( nutxo:nutxo ) ASSERT nutxo.outpoint IS UNIQUE;"}]}'
#################################################
#
#
# Updating node-config.yaml
#
#
echo "Updating node-config.yaml"
nodeconfig=xoken/node-config.yaml
grep -q '^neo4jPassword.*' $nodeconfig && sed -i "s/neo4jPassword.*/neo4jPassword: $neo4jpassword /" $nodeconfig || echo "neo4jPassword: $neo4jpassword" >> $nodeconfig
#################################################
#
#
# Wait until cassandra starts running and run queries present in schema.cql
#
#
while ! cqlsh -e 'describe cluster' ; do
    sleep 3
    echo "Waiting until cassandra starts running"
done
echo "Running queries present in schema.cql"
cqlsh -f /opt/xoken/schema.cql
#################################################
#
#
# Restarting cassandra and neo4j
#
#
echo "Restarting cassandra"
ps -ef | grep cassandra | awk '{print $2}' | xargs -I{} kill {}
gnome-terminal --title=newWindow -- bash -c "/opt/apache-cassandra-3.11.6/bin/cassandra; bash"
while ! cqlsh -e 'describe cluster' ; do
    sleep 3
    echo "Waiting until cassandra starts running"
done
echo "Restarting neo4j"
(cd /opt/neo4j-community-3.5.20/bin ; ./neo4j restart )
#################################################
#sudo rm osversion.txt
cd xoken
#################################################
#
#
# Generating SSL certificate with default userdetails
#
#
openssl req -newkey rsa:4096 -x509 -subj '/C=NA/ST=NA/L=NA/CN=NA' -sha256 -days 3650 -nodes -out example.crt -keyout example.key
#################################################
#
#
# Starting Xoken Nexa
#
#
echo "Starting Xoken Nexa"
./xoken-nexa
