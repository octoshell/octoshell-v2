daemonize false
environment 'production'
bind "unix:///var/www/octoshell2/socket"
#bind "tcp://localhost:5000"

threads 1, 8

stdout_redirect "/var/www/octoshell2/shared/log/web_stdout.log", "/var/www/octoshell2/shared/log/web_stderr.log", true
