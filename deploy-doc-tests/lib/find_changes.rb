# This function parses the YAML file in <gitroot>/deploy/kubernetes/complete-demo.yaml,
# and extracts all used images.
def find_images_in_k8s_complete_demo
  images = []
  yaml_parts = File.read(REPO_ROOT.join("deploy").join("kubernetes").join("complete-demo.yaml"))\
    .split("---\n")\
    .select{ |part| part.to_s != "" }
    .map { |part| YAML.load(part) }

  yaml_parts \
    .select { |part| part["kind"] == "Deployment" }\
    .map { |part| part["spec"]["template"]["spec"]["containers"].map { |c| c["image"] } }.flatten\
    .map { |name| if name.include?(":") then name; else name + ":latest"; end }.uniq
end

# Checks if any of the +image_list+ images on the docker hub have been changed since +since+.
def any_image_changed_since?(image_list, since)
  log(:info, "Checking if any of #{image_list.join(", ")} has changed since #{since.rfc2822}")

  changed_images = image_list.select do |img|
    log_system_or_die(:debug, "docker pull #{img}")
    created_at = Time.parse JSON.load(capture_or_die("docker inspect #{img}")).first["Created"]
    changed = created_at > since
    update_text = if changed
                    "changed"
                  else
                    "not changed"
                  end
    log(:debug, "Image #{img} last updated at #{created_at.rfc2822}. It was #{update_text} since #{since.rfc2822}")
    changed
  end

  if changed_images.any?
    log(:info, "Yep, #{changed_images.join(", ")} have changed.")
    true
  else
    log(:info, "No, nothing changed.")
    false
  end

  exit 1
end

def deployment_changed?(exec_depl_doc, since)
  last_deploy_change = Time.parse(capture_or_die("git log -n1 --pretty=format:%cD -- #{exec_depl_doc.deployment_directory}"))
  last_deployment_doc_change = Time.parse(capture_or_die("git log -n1 --pretty=format:%cD -- #{exec_depl_doc.markdown_file}"))

  changed = false
  if last_deployment_doc_change > since
    log(:debug, "Something in the DeployDoc for #{exec_depl_doc.name} has changed since #{since.rfc2822}")
    changed = true
  end
  if last_deploy_change > since
    log(:debug, "Something in the deployment scripts for #{exec_depl_doc.name} has changed since #{since.rfc2822}")
    changed = true
  end

  if changed
    log(:info, "DeployDoc or script for #{exec_depl_doc.name} has changed since #{since.rfc2822}")
  end

  changed
end
