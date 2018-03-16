# frozen_string_literal: true

app_dir = '/usr/src/app'

working_directory app_dir

pid "#{app_dir}/tmp/unicorn.pid"

worker_processes 2

listen 3000, tcp_nopush: false
