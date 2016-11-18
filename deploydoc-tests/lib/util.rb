DEBUG_LEVELS = [:debug, :info]
DEBUG_LEVEL = if ENV["DEBUG"]
                :debug
              else
                :info
              end

def log(level, msg)
  if DEBUG_LEVELS.index(level) >= DEBUG_LEVELS.index(DEBUG_LEVEL)
    puts msg
  end
end

def log_system_or_die(level, cmd)
  log(level, "Run '#{cmd}':")
  log(level, capture_or_die(cmd))
end

def capture_or_die(cmd)
  output = `#{cmd}`
  if $?.exitstatus != 0
    raise("Failed to run #{cmd}")
  end
  output
end

def running_on_travis?
  ENV.has_key?("TRAVIS_EVENT_TYPE")
end
