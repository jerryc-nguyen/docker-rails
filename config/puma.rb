# Before configuring Puma, you should look up the number of CPU cores your server has, change this to match your CPU core count
workers Integer(ENV['WEB_CONCURRENCY'] || [1, `grep -c processor /proc/cpuinfo`.to_i].max)
threads_count = Integer(ENV['MAX_THREADS'] || 5)
threads threads_count, threads_count

# HTTP interface
port ENV.fetch("PUMA_PORT") { 4000 }

stdout_redirect(stdout = '/dev/stdout', stderr = '/dev/stderr', append = true)

on_worker_boot do
  require "active_record"
  ActiveRecord::Base.connection.disconnect! rescue ActiveRecord::ConnectionNotEstablished
  ActiveRecord::Base.establish_connection
end


before_fork do
  require 'puma_worker_killer'

  total_ram = (ENV.fetch("PWK_TOTAL_RAM") || 1800).to_i
  percent = (ENV.fetch("PWK_RAM_PERCENT") || 0.5).to_f

  p "================================================="
  p "PWK CONFIG RAM: #{total_ram}, PERCENT: #{percent}"

  PumaWorkerKiller.config do |config|
    config.ram           = total_ram # mb
    config.frequency     = 120  # seconds
    config.percent_usage = percent
    config.rolling_restart_frequency = 2 * 3600 # 2 hours in seconds
  end

  PumaWorkerKiller.start
end
