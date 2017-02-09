require "pp"
require "travis-cron_tools"

# Domain specific struct to encode a custom dependency
DeploymentPlatform = Struct.new(:name, :markdown_file)

# Instantiate travis client for this repository.
travis = Travis::CronTools::TravisAPI.new("microservices-demo", "microservices-demo")

###############################################################################
# Find time to compare changes against
###############################################################################

# Find time to compare changes against
# This guarrantees that we won't miss any changes.

last_cron_job = travis.builds(event_type: "cron").first
last_cron_job_start_time = Time.parse(last_cron_job["started_at"])

last_cron_job_start_time = (Date.today - 30).to_time

puts "Checking for changes after #{last_cron_job_start_time.rfc2822}"
puts "(That is when the previous cron job started)"

###############################################################################
# Find dependencies
###############################################################################

# In the contrib module, there are some helper methods.
# Below for example, it extracts all image names from a k8s manifest file.
docker_images = Travis::CronTools::Contrib.find_images_in_k8s_manifest("deploy/kubernetes/complete-demo.yaml")

# Find documented platforms
deployment_platforms = Dir["docs/deployment/*.md"].map do |markdown_file|
  name = File.basename(markdown_file).gsub(/\.md$/, "")

  # Extract the yaml header from the top of the file
  yaml = YAML.load(File.read(markdown_file).split("---")[1]) rescue {}
  if yaml["deployDoc"] == true
    DeploymentPlatform.new(name, markdown_file)
  else
    nil
  end
end.reject(&:nil?)

###############################################################################
# Determine which tests to run
###############################################################################

platforms_to_test = []

# Implement custom logic to determine what  should be tested.
# In this case, if any of the docker images has changed, we want to test
# all different platforms we can deploy to.
if docker_images.any? { |image| image.created_since?(last_cron_job_start_time) }
  puts "Some of the docker images changed; building all platforms"
  platforms_to_test = deployment_platforms
else
  # Alternatively, if none of the images has changed, we check if any deployment has changed
 # in the git repository since the last successfull build.
 puts "None of the docker images changed."
 deployment_platforms.each do |platform| 
    git_dir = SpawnTravisBuild::Dependency::Git.new(platform.dir)
    if git_dir.changed_since?(last_cron_job_start_time)
      puts "However, deployment platform #{platform.name} changed"
      platforms_to_test.push platform
    end
  end
end

###############################################################################
# Create Travis Build
###############################################################################

if platforms_to_test.empty?
  puts "No platform tests to schedule :)"
else
  # Now we create the travis build.
  # Note that we use the reset_dot_travis_yml helper; this configuration is MERGED with
  # the existing configuration

  cron_build_number = ENV["TRAVIS_BUILD_NUMBER"]
  travis_build_request = {
    message: "[deployment-daily-ci] spawned by cron build #{cron_build_number}",
    commit: ENV["TRAVIS_COMMIT"],
    config: Travis::CronTools.reset_dot_travis_yml.merge({
      language: "generic",
      sudo: true,
      services: ["docker"],
      install: ["gem install deploy_doc"],
      env: {
        global: [ "SPAWNED_BY_CRON_BUILD=#{cron_build_number}" ],
        matrix: platforms_to_test.map { |platform| "DEPLOY_DOC=#{platform.markdown_file}" }
      },
      script: [
        "export AWS_ACCESS_KEY_ID=$DEPLOY_DOC_AWS_ACCESS_KEY",
        "export AWS_SECRET_ACCESS_KEY=$DEPLOY_DOC_AWS_SECRET_ACCESS_KEY",
        "deploy_doc $DEPLOY_DOC -r"
      ],

      # Overwrite deploy step with a no-op.
      deploy: {
        provider: "script",
        script: "true"
      },

      notifications: {
        slack: {
          rooms: {
            secure: "p9hoJ6bSxBNdRqrnOFQC+FHAkfhRAw+nxy27lCBwWRVTimB03Ja14RWUKIYkmmEt0WCAW7gQxPM4JHmoczIyaDjNmk5F+mw584ctqeBlKhdIq73RIKSilBwdo9aTCgTVPVuKyRqNIaESWmA95zs1NqTi1Hbf0ER22pFszetqfrQwdDpVK8siwLV6pOtqG+ugz9XWksCYbD+86PA9j9SNuVDTbBF2oI9xuXQ9tmubbJCoRTFBrDPiGMTd2pFqNUmL2naXVrNqNbhI5uTu2wKxGUTU9KZeRDN/a+M1nGh0Aegi+b8khioQ5/TmOfLALya/spLGqKGDK16TIAQXiVenaXlUkQ089td9jOMs8X/dk3fVsnq8hObLS5b//waSqU/x9miEGcDFiEWke8N+IG2e1PB/UjVyI02tdwQ/2XLMWuZIZtxHhcpLArCV/QZNvza0OhshvIQD+2e5kVD6er2iuXjJ3kex6rufAkMXNI1YzbHofLnmoH6XwZMaBWUa4yhivFp9vkggwEWUN/ZIgJnCmy8I9qM82IHlLDl3hdklRZlhexNhXnBxgc+bK0duMIC2qzQJq1Cfb555D5DWqph1PlrcMnrKmKvC2uJFhhsKHuo3jSa/WR/JHUg1WEWdh4gQVFIz0f/FgGM5wXm20pZn8l4rVkEoUT3KWztINNFjA9E="
          },
          on_success: "always",
          on_failure: "always",
          on_start: "always",
          on_pull_requests: "false"
        }
      }
    })
  }

  puts
  puts "Posting Travis build request:"
  puts
  pp travis_build_request
  travis.create_request(travis_build_request)
end
