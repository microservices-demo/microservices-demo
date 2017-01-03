job "logging-fluentd" {
  datacenters = ["dc1"]
  type = "system"

  constraint {
    attribute = "${attr.kernel.name}"
    value = "linux"
  }

  update {
    stagger = "10s"
    max_parallel = 1
  }

  # - fluentd - #
  task "fluentd" {
    driver = "docker"

    config {
      image = "seqvence/log-server"
      hostname = "fluentd.weave.local"
      network_mode = "external"
      dns_servers = ["172.17.0.1"]
      dns_search_domains = ["weave.local."]
      logging {
        type = "json-file"
      }
      volumes = [
         "/var/lib/docker/containers:/var/lib/docker/containers"
      ]
    }

    env {
      FLUENTD_CONF = "elk.conf"
    }

    resources {
      cpu = 100 # 50 Mhz
      memory = 300 # 10Mb
      network {
        mbits = 10
      }
    }    

  }
  # - end fluentd - #

}
