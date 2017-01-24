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

#mongo = {
#  image: "mongo",
#  port: 27017,
#  standard_probes: false,
#  security: {
#    capabilities: {
#      drop: [ "all" ],
#      add: [ "CHOWN", "SETGID", "SETUID" ]
#    },
#    readOnlyRootFilesystem: true
#  }
#}
#
#zipkin_env = {
#  ZIPKIN: "http://zipkin:9411/api/v1/spans"
#}
#
#sock_shop = MyApp.new(ENV['NAMESPACE'] || "sock-shop", [
#  mongo.merge({
#    name: "cart-db"
#  }),
#  {
#    image: "weaveworksdemos/cart:0.4.0",
#    prometheus_path: "/prometheus"
#  },
#  {
#    image: "weaveworksdemos/catalogue-db:0.3.0",
#    port: 3306,
#    standard_probes: false,
#    security: {},
#    env: {
#      MYSQL_ROOT_PASSWORD: "fake_password", MYSQL_DATABASE: "socksdb"
#    }
#  },
#  {
#    image: "weaveworksdemos/catalogue:0.3.0",
#    env: zipkin_env
#  },
#  {
#    image: "weaveworksdemos/front-end:0.3.0",
#    port: 8079,
#    service_port: 80,
#    service_type: "NodePort",
#    service_session_affinity: "ClientIP"
#  },
#  mongo.merge({
#    name: "orders-db"
#  }),
#  {
#    image: "weaveworksdemos/orders:0.4.2",
#    prometheus_path: "/prometheus"
#  },
#  {
#    image: "weaveworksdemos/payment:0.4.0",
#    env: zipkin_env
#  },
#  {
#    image: "weaveworksdemos/queue-master:0.3.0",
#    security: {},
#    prometheus_path: "/prometheus"
#  },
#  {
#    image: "rabbitmq:3",
#    port: 5672,
#    standard_probes: false,
#    security: {
#      capabilities: {
#        drop: [ "all" ],
#        add: [ "CHOWN", "SETGID", "SETUID", "DAC_OVERRIDE" ]
#      },
#      readOnlyRootFilesystem: true
#    }
#  },
#  {
#    image: "weaveworksdemos/shipping:0.4.0",
#    prometheus_path: "/prometheus"
#  },
#  mongo.merge({
#    image: "weaveworksdemos/user-db:0.3.0"
#  }),
#  {
#    image:
#    "weaveworksdemos/user:0.4.0",
#    env: zipkin_env.merge({
#      MONGO_HOST: "user-db:27017"
#    })
#  },
#  {
#    image: "openzipkin/zipkin",
#    port: 9411,
#    security: {},
#    standard_probes: false,
#    service_type: "NodePort"
#  }
#])

sock_shop = MyApp.new(ENV['NAMESPACE'] || "sock-shop", YAML.load(File.open('services.yaml'))["services"])
sock_shop.write_files!
