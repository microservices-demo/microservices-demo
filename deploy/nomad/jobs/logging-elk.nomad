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
      cpu = 200 # 50 Mhz
      memory = 800 # 10Mb
      network {
        mbits = 50
      }
    }    

  }
  # - end elasticsearch - #

}