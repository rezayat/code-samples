   sudo npm -g uninstall elm-live    \
&& sudo npm -g uninstall elm-oracle  \
&& sudo npm -g uninstall elm-format  \
&& sudo npm -g uninstall elm-test	 \
&& sudo npm -g uninstall elm


sudo apt-get purge -yq   	    \
   nodejs						\
   closure-compiler 			\
&& sudo apt-get autoremove -y 	\
&& sudo apt-get autoclean 		\
&& sudo apt-get clean
