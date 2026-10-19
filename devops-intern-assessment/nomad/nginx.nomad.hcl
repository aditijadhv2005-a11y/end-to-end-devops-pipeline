variable "image" {
  type        = string
  description = "Immutable container image reference, preferably tagged with the Git commit SHA."
}

variable "force_pull" {
  type        = bool
  description = "Pull the image from its registry. Set false only when the image is already present on the Nomad client."
  default     = true
}

job "nginx-web" {
  datacenters = ["dc1"]
  type        = "service"

  group "web" {
    count = 1

    network {
      mode = "bridge"
      port "http" {
        static = 8080
        to     = 80
      }
    }

    restart {
      attempts = 3
      interval = "5m"
      delay    = "15s"
      mode     = "fail"
    }

    update {
      max_parallel      = 1
      min_healthy_time  = "10s"
      healthy_deadline  = "3m"
      progress_deadline = "5m"
      auto_revert       = true
    }

    task "nginx" {
      driver = "docker"

      config {
        image      = var.image
        ports      = ["http"]
        force_pull = var.force_pull
      }

      resources {
        cpu    = 100
        memory = 64
      }

      service {
        name     = "nginx-web"
        provider = "nomad"
        port     = "http"

        check {
          name     = "nginx-http-health"
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
