require 'json'
require 'yaml'

class MyApp
  def initialize(namespace, services)
    @namespace = namespace
    @services = services.map { |service| MyApp::Service.new(service.merge({ namespace: namespace })) }
  end

  def write_files!
    Dir.mkdir(@namespace) unless Dir.exists?(@namespace)
    @services.each { |service| service.write_files! }
  end

  class Service

    DEFAILT_NAMESPACE = "default"
    DEFAULT_PORT = 80
    DEFAULT_REPLICAS = 1

    def get(opts, key)
      opts[key] || opts[key.to_s]
    end

    def initialize(opts)
      @image = get(opts, :image)

      @name = get(opts, :name) || @image.split(':')[0].split('/').last

      @namespace = get(opts, :namespace) || DEFAILT_NAMESPACE
      @port = get(opts, :port) || DEFAULT_PORT
      @replicas = get(opts, :replicas) || DEFAULT_REPLICAS

      @labels = { name: @name }
      @metadata = {
        name: @name,
        labels: @labels,
        namespace: @namespace
      }

      @deployment = self.make_deployment!
      @container = @deployment[:spec][:template][:spec][:containers][0]

      @service = self.make_service!

      if get(opts, :env).is_a? Hash
        @container[:env] = get(opts, :env).map { |k,v| { name: k.to_s, value: v } }
      end

      add_standard_probes unless get(opts, :standard_probes) == false

      if get(opts, :security).is_a? Hash
        @container[:securityContext] = get(opts, :security)
      end

      if get(opts, :service_port)
        @service[:spec][:ports][0][:port] = get(opts, :service_port)
      end

      if get(opts, :service_type)
        @service[:spec][:type] = get(opts, :service_type)
      end

      if get(opts, :service_session_affinity)
        @service[:spec][:sessionAffinity] = get(opts, :service_session_affinity)
      end

      if get(opts, :prometheus_path)
        @service[:metadata][:annotations] = { "prometheus.io/path" => get(opts, :prometheus_path) }
      end
    end

    def add_standard_probes
      probe = {
        httpGet: { path: "/health", port: @port },
        periodSeconds: 3,
      }

      @container[:livenessProbe] = probe.merge({ initialDelaySeconds: 300 })
      @container[:readinessProbe] = probe.merge({ initialDelaySeconds: 180 })
    end

    def make_deployment!
      {
        apiVersion: 'extensions/v1beta1',
        kind: 'Deployment',
        metadata: @metadata.clone,
        spec: {
          replicas: @replicas,
          template: {
            metadata: { labels: @labels },
            spec: {
              containers: [{
                name: @name,
                image: @image,
                ports: [{ containerPort: @port }],
                securityContext: {
                  runAsNonRoot: true,
                  runAsUser: 10001,
                  capabilities: { drop: [ "all" ], add: [ "NET_BIND_SERVICE" ] },
                  readOnlyRootFilesystem: true
                },
                volumeMounts: [{ name: "tmp-volume", mountPath: "/tmp" }],
              }],
              volumes: [{
                name: "tmp-volume",
                emptyDir: { medium: "Memory" },
              }]
            }
          }
        }
      }
    end

    def make_service!
      {
        apiVersion: 'v1',
        kind: 'Service',
        metadata: @metadata,
        spec: {
          ports: [{
            port: @port,
            targetPort: @port
          }],
          selector: @labels
        }
      }
    end

    def serialize hash
      ## YAML dumper seems to enforce keys to be like symbols,
      ## converting to JSON and back to YAML does the job.
      JSON.load(hash.to_json).to_yaml
    end

    def write_files!
      Dir.mkdir(@namespace) unless Dir.exists?(@namespace)
      deployment_file_path = File.join(Dir.pwd, @namespace, "#{@name}-dep.yaml")
      File.open(deployment_file_path, 'w') { |file| file.write(serialize(@deployment)) }
      service_file_path = File.join(Dir.pwd, @namespace, "#{@name}-svc.yaml")
      File.open(service_file_path, 'w') { |file| file.write(serialize(@service)) }
    end
  end
end

sock_shop = MyApp.new(ENV['NAMESPACE'] || "sock-shop", YAML.load(File.open('services.yaml'))["services"])
sock_shop.write_files!
