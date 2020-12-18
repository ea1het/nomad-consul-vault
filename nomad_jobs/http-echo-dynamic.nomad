//
// Jonathan Gonzalez
// j@0x30.io
// https://github.com/EA1HET
// Nomad v1.0.0 
// Plan date: 2020-12-15
// Job version: 1.0
//
// A debug container to test network infrastructure, i.e. load balancers and WAFs
//

job "http-echo-dynamic" {
  datacenters = ["LAB"]  
  group "echo" {
    count = 3
    
    task "server" {
      driver = "docker"
    
      env {
        ECHO_MESSAGE = "${NOMAD_IP_http}:${NOMAD_PORT_http} - Meta: ${NOMAD_META_VERSION}"
        SERVER_PORT = ${NOMAD_PORT_http}
      }
      
      config {
        image = "teapow/http-echo:armv7"
      }

      resources {
        // Hardware limits in this cluster       
        cpu = 500
        memory = 512        
        network {
          mbits = 100
          port "http" {}
        }
      }       
      
      service {
        name = "http-echo-dynamic"
        port = "http"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.http.rule=Path(`/app`)",
          ]
        check {
          name = "alive"
          type = "http"
          path = "/"
          interval = "10s"
          timeout = "2s"
        }
      }

      meta {
        VERSION = "v1.0"
      }      
      
    } // EndTask
  } // EndGroup
} // EndJob
