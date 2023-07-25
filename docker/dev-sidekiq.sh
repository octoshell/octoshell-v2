#!/bin/sh
bundle exec sidekiq -q announcements_mailer -q pack_worker -q auth_mailer -q core_mailer -q sessions_mailer -q sessions_validator -q sessions_starter -q stats_collector -q support_mailer -q synchronizer -q cloud_computing_task_worker -q perf_queue
