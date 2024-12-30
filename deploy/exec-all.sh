for s in octoshell-web job-sidekiq sidekiq
do
        systemctl $1 --user $s
done
