#daemonize false
environment 'production'
bind "unix://!deploy_to!/socket"
#bind "tcp://0.0.0.0:5000"

threads 4,20
workers 2

#stdout_redirect "/var/www/octoshell2/shared/log/web_stdout.log", "/var/www/octoshell2/shared/log/web_stderr.log", true
