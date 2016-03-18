# This script waits until the deployed revision starts being used. Useful
# when using herokus preload feature to avoid downtime.

# Time before giving up in seconds
TIMEOUT = 60 * 10

app_name, revision = ARGV
url = "https://#{app_name}.herokuapp.com/revision"

puts
print "Waiting for the app to start serving requests using #{revision}..."; STDOUT.flush

start = Time.now
loop do
  current_revision = `curl -s #{url}`.chomp

  unless current_revision
    puts "WARNING: Couldn't find current revision! SOURCE -> #{current_html} <- SOURCE"
  end

  break if current_revision == revision

  sleep 1

  if Time.now - start > TIMEOUT
    Kernel.abort("Timed out waiting for #{revision} to be the active revision on #{url}")
  end

  print "."
  STDOUT.flush
end

puts
puts "Done in #{(Time.now - start).to_i} seconds"
