worker_processes 4
timeout 30
listen 5000

require 'pathname'

path = Pathname.new(__FILE__).realpath # 当前文件完整路径

path = path.sub('/config/unicorn.rb', '')

APP_PATH = path.to_s

# unicorn 日志

stderr_path APP_PATH + "/log/unicorn.stderr.log"

stdout_path APP_PATH + "/log/unicorn.stdout.log"

# combine Ruby 2.0.0dev or REE with "preload_app true" for memory savings
# http://rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
preload_app true
GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true

# Enable this flag to have unicorn test client connections by writing the
# beginning of the HTTP headers before calling the application.  This
# prevents calling the application for connections that have disconnected
# while queued.  This is only guaranteed to detect clients on the same
# host unicorn runs on, and unlikely to detect disconnects even on a
# fast LAN.
check_client_connection false

# local variable to guard against running a hook multiple times
run_once = true

before_fork do |server, worker|
# the following is highly recomended for Rails + "preload_app true"
# as there's no need for the master process to hold a connection
defined?(ActiveRecord::Base) and
ActiveRecord::Base.connection.disconnect!
# Occasionally, it may be necessary to run non-idempotent code in the
# master before forking.  Keep in mind the above disconnect! example
# is idempotent and does not need a guard.
if run_once
  # do_something_once_here ...
  run_once = false # prevent from firing again
end

after_fork do |server, worker|
# the following is *required* for Rails + "preload_app true",
  defined?(ActiveRecord::Base) and
  ActiveRecord::Base.establish_connection
end
