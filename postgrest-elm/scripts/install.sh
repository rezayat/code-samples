#!/usr/bin/env bash

echo "Installing for local development"
echo "Assumes ubuntu 16.04 LTS platform"


echo "update nodejs from PPA"
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -


echo "Installing nodejs + javascript tools"
   sudo apt-get update  	\
&& sudo apt-get install -yq \
   nodejs 					\
   closure-compiler 		\
&& apt-get autoremove -y 	\
&& apt-get autoclean 		\
&& apt-get clean

echo "Installing python tools"
sudo -H pip install \
	httpie 			\
	httpie-jwt-auth \
	pytest

echo "Installing elm + tools"
   sudo npm install -g elm@0.18.0      \
&& sudo npm install -g elm-test@0.18.0 \
&& sudo npm install -g elm-format@exp  \
&& sudo npm install -g elm-oracle	   \
&& sudo npm install -g elm-live
