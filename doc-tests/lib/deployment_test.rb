require "yaml"
# This class models a reference to executable documentation.
class DeploymentTest < Struct.new(:name, :markdown_file, :deployment_directory, :config)
  require_relative "deployment_test/plan"

  def self.find!(name)
    edd = DeploymentTest.find_all.find { |edd| edd.name == name }
    if edd.nil?
      $stderr.puts "Executable deployment documentation for #{name} not found."
      exit 1
    else
      edd
    end
  end

  def self.find_all
    md_files = Dir[File.expand_path("../../../docs/deployment/*.md", __FILE__)]
    all = []
    md_files.each do |md_file|
      # These Jekyll markdown files have a '---' on the first line, then a YAML document, ended by
      # another '---'. Splitting on "---", taking the 2nd element => 1th index on 0-index based languages.
      yaml = YAML.load File.read(md_file).split("---")[1]

      if yaml["executableDocumentation"] == true
        name = File.basename(md_file).gsub(/\.md$/,"")
        script_dir_name = if yaml.has_key?("deploymentScriptDir")
                            yaml["deploymentScriptDir"]
                          else
                            name
                          end
        script_dir = File.expand_path("../../../deploy/#{script_dir_name}",__FILE__)
        if ! Dir.exist? script_dir
          raise("Could not find a $repo/deploy/#{name} directory!")
        end
        all << DeploymentTest.new(name, md_file, script_dir, yaml)
      end
    end

    all
  end

  def plan
    @plan ||= Plan.from_file(self.markdown_file)
  end
end
