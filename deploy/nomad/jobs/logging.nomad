job "logging" {

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
      }

    }
    # - end fluentd - #

}