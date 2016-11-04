require "yaml"
class DeployDocTest < Struct.new(:name, :markdown_file, :deployment_directory, :config)
  require_relative "deploy_doc_test/plan"

  def self.find!(name)
    deploy_doc_test = DeployDocTest.find_all.find { |deploy_doc_test| deploy_doc_test.name == name }
    if deploy_doc_test.nil?
      $stderr.puts "Executable deployment documentation for #{name} not found."
      exit 1
    else
      deploy_doc_test
    end
  end

  def self.find_all
    md_files = Dir[REPO_ROOT.join("docs").join("deployment").join("*.md")]
    all = []
    md_files.each do |md_file|
      # These Jekyll markdown files have a '---' on the first line, then a YAML document, ended by
      # another '---'. Splitting on "---", taking the 2nd element => 1th index on 0-index based languages.
      yaml = YAML.load File.read(md_file).split("---")[1]

      if yaml["deployDoc"] == true
        name = File.basename(md_file).gsub(/\.md$/,"")
        script_dir_name = if yaml.has_key?("deploymentScriptDir")
                            yaml["deploymentScriptDir"]
                          else
                            name
                          end
        script_dir = REPO_ROOT.join("deploy").join(script_dir_name)
        if ! Dir.exist? script_dir
          raise("Could not find a $repo/deploy/#{name} directory!")
        end
        all << DeployDocTest.new(name, md_file, script_dir, yaml)
      end
    end

    all
  end

  def plan
    @plan ||= Plan.from_file(self.markdown_file)
  end
end
