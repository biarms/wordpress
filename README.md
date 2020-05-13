# Brothers in ARMs' project

[![build status](https://api.travis-ci.org/biarms/wordpress.svg?branch=master)](https://travis-ci.org/biarms/wordpress)

This image is actually based on WordPress official image, version 5.4.1-php7.3-fpm-alpine.
The only differences are
1. The addition of the 'baskerville' and the 'travelera-lite' themes
2. The removal of the default (commerical) wordpress plugin and the addition of some other plugins
3. The configuration of the php settings to authorize the upload of files with a size greater than 2MB.
Resulting docker images are pushed on [dockerhub](https://hub.docker.com/r/biarms/wordpress/).


### Tips:
1. It is a good idea to increase the 'upload_max_filesize' php.ini parameter according to your wish: the folder php-conf.d provide sample file to see how to do.
1. If wordpress is installed behind an ngnix reverse proxy, the some 'nginx timeouts' should be increased (because installing the JetPack plugin is for instance very time-consuming, especially is your backend is an arm device (a rock-64 2GB device) running on a single Kubernetes nodes with an nfs provisioner accessing an NFS mount drive shared by an Odroid server !).
   Here is a debugging session of the installation of this plugin on the previously described setup, accessible via an NGX reverse proxy hosted on a Synology server:
   ```
   # First, upload the files on the 'wp-content/update' folder:
   $ watch -n 0.2 -d "du -sh wp-content/upgrade/jetpack*"
   => upload 27MB !
   # Then copy the file on the ' wp-content/plugins/jetpack' folder:
   $ watch -n 0.2 -d "du -sh wp-content/plugins/jetpack"
   1M     wp-content/plugins/jetpack
   2M     wp-content/plugins/jetpack
   ...
   27M     wp-content/plugins/jetpack
   # Then delete the files on the initial folder (that's also very time-consuming !!!!):
   $ watch -n 0.2 -d "du -sh wp-content/upgrade/jetpack*"
   27M     wp-content/upgrade/jetpackXXX
   26M     wp-content/upgrade/jetpackXXX
   ...
   1M      wp-content/upgrade/jetpackXXX
   du: cannot access 'wp-content/upgrade/jetpack*': No such file or directory
   # If the reverse proxy ngnix timeouts are not big enough (see next section):
   $ sudo tail -f /var/log/nginx/error.log (on the reverse proxy server, in my case, my synology server)
   # will return :
   2020/04/30 21:57:45 [error] 1759#1759: *163253 upstream timed out (110: Connection timed out) while reading response header from upstream...
   ```
1. In order to increase timeout on Synology: "Control Panel -> Application Portal -> Reverse proxy -> Edit -> Advanced settings" will authorize to change:
   - proxy_connect_timeout 600
   - proxy_send_timeout 600
   - proxy_read_timeout 600
1. To debug the previous step (on Synology): `cat /etc/nginx/app.d/server.ReverseProxy.conf`
