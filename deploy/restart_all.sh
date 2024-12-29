for s in octoshell-web job-sidekiq sidekiq
do
        systemctl restart --user $s
done
