class DeploymentTest
  class Plan
    require_relative "plan/annotator_parser"

    PHASES = ["pre-install", "create-infrastructure", "run-tests", "destroy-infrastructure"]

    class Step < Struct.new(:source_name, :line_span, :shell)
      def full_name
        "#{source_name}:#{line_span.inspect}"
      end
    end

    def self.from_file(file)
      annotations = AnnotationParser.parse_file(file)
      Plan.from_annotations(annotations)
    end

    def self.from_annotations(annotations)
      required_env_vars = (annotations.select { |a| a.kind == "require-env" }).map { |a| a.params }.flatten
      phases = {}

      PHASES.each do |phase|
        phases[phase] = (annotations.select { |a| a.kind == phase }).map { |a| Step.new(a.source_name, a.line_span, a.content) }
      end

      Plan.new(required_env_vars, phases)
    end

    attr_reader :required_env_vars

    def initialize(required_env_vars, steps_in_phases)
      @required_env_vars = required_env_vars
      @steps_in_phases = steps_in_phases
    end

    def to_s
     parts = []
     parts << "Deployment test plan:"
     parts << ""
     parts << "Required environment parameters"

     @required_env_vars.each do |e|
       parts << "  - #{e}"
     end

     PHASES.each do |phase|
       parts << "Steps in phase #{phase}:"
       @steps_in_phases[phase].each do |step|
         parts << "- #{step.source_name}:#{step.line_span.inspect}"
         parts << step.shell
       end
     end

     parts.join("\n")
    end

    def missing_env_vars
      @required_env_vars.select { |e| ENV[e].nil? }
    end

    def execute!
      if missing_env_vars.any?
        $stderr.puts "Missing the following required environment variables:"
        $stderr.puts missing_envs.inspect
        exit 1
      end

      execute_phase("pre-install")
      begin
        execute_phase("create-infrastructure")
        execute_phase("run-tests")
        return true
      rescue Exception => e
        p e
        return false
      ensure # Clean up the infrastructure
        begin
          execute_phase("destroy-infrastructure")
          rescue Exception  => e
          $stderr.puts "Failed to clean up  the infrastructure!"
          exit 2
        end
      end
    end

    def execute_phase(phase_name)
      puts "Executing phase #{phase_name}"
      steps = @steps_in_phases[phase_name]

      steps.each do |step|
        puts "Running step #{step.full_name}"
        system(step.shell)
        if $?.exitstatus != 0
          raise("Could not finish step #{step.full_name} in phase #{phase_name}")
        end
      end
    end
  end
end
