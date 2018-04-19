RAILS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../../../../.."
DIFF=$(diff $RAILS_DIR/config/nginx_config /etc/nginx/sites-enabled/octo)
if [ "$DIFF" == "" ]
then
  echo 'nginx_config is not  modified'
else
  echo 'nginx_config is modified'
  sudo rm -f /etc/nginx/sites-available/old_octo
  sudo mv  /etc/nginx/sites-enabled/octo /etc/nginx/sites-available/old_octo
  sudo cp  $RAILS_DIR/config/nginx_config /etc/nginx/sites-enabled/octo
  sudo service nginx restart
fi
sudo apt-get update
sudo apt-get install -y nodejs
