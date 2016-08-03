job "netman" {
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

  # - Frontend group #
  group "main" {
    count = 1

    # - Main app - #
    task "netman" {
      driver = "raw_exec"

      config {
        command = "/usr/bin/netman"
      }

      resources {
        cpu = 50 # 50 Mhz
        memory = 10 # 10Mb
        network {
          mbits = 10
        }
      }
    }
    # - End main app - #
  }
  # - End main group - #
}
