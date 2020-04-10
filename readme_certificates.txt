#Private key
openssl genrsa -des3 -out certs/domain.key 1024
#CSR
openssl req -new -key certs/domain.key -out certs/domain.csr
#Remove Passphrase
cp certs/domain.key certs/domain.key.org
openssl rsa -in certs/domain.key.org -out certs/domain.key
#Generate self signed certificate
openssl x509 -req -days 365 -in certs/domain.csr -signkey certs/domain.key -out certs/domain.crt
chmod 400 certs/domain.key

#In every docker host
#copy  /etc/docker/certs.d/docker-registry:5000/ca.crt
sudo cp local_environment_configs/domain.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates
sudo systemctl restart docker
