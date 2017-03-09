job "logging-elk" {
  datacenters = ["dc1"]
  type = "service"

  constraint {
    attribute = "${attr.kernel.name}"
    value = "linux"
  }

  update {
    stagger = "10s"
    max_parallel = 1
  }

  # - logging-elk - #
  group "logging-elk" {

    # - elasticsearch - #
    task "elasticsearch" {
      driver = "docker"

      config {
        image = "elasticsearch"
        hostname = "elasticsearch.weave.local"
        network_mode = "external"
        dns_servers = ["172.17.0.1"]
        dns_search_domains = ["weave.local."]
        logging {
          type = "json-file"
        }
      }

      resources {
        memory = 3000
        network {
          mbits = 50
        }
      }

    }
    # - end elasticsearch - #

    # - kibana - #
    task "kibana" {
      driver = "docker"

      config {
        image = "kibana"
        hostname = "kibana.weave.local"
        network_mode = "external"
        dns_servers = ["172.17.0.1"]
        dns_search_domains = ["weave.local."]
        logging {
          type = "json-file"
        }
      }

      resources {
        memory = 2000
        network {
          mbits = 50
          port "kibana" {
            static = "5601"
          }
        }
      }

    }
    # - end kibana - #

  } # - end logging-elk - #

}
