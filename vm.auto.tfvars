# ### Define Tenant ###
# tenant = "Production"
#
# ### Define Azure Apps ###
# azure_apps = {
#   hrapp1 = {
#     name = "hrapp1" # ANP name
#     segment = "hr" # VRF name
#     regions = {
#       australiasoutheast = {
#         name = "australiasoutheast"
#         vpc_cidr = "10.2.2.0/24"
#         instances = {
#           web = {
#             tier = "web" # EPG
#             subnet_cidr = "10.2.2.32/28"
#             instance_name = "hrapp1-web"
#             instance_count = 1
#           }
#           db = {
#             tier = "db" # EPG
#             subnet_cidr = "10.2.2.48/28"
#             instance_name = "hrapp1-db"
#             instance_count = 1
#           }
#         }
#       }
#     }
#   }
# }

### Define Tenant ###
tenant = "Production"

### vSphere Details ###
vsphere_datacenter  = "CPOC-HX"
vsphere_cluster     = "CPOC-HX"
vsphere_datastore   = "CPOC-HX"
vsphere_template    = "ubuntu-svr-template-20.04"

### Domain ###
domain          = "cpoc.local"
dns_server_list = ["100.64.62.199", "8.8.8.8"]

### Define On-Premise DC Apps ###
dc_apps = {
  hrapp1 = {
    name = "hrapp1" # ANP name
    segment = "hr" # VRF name
    instances = {
      web = {
        tier = "web" # EPG name
        instance_name = "hrapp1-web"
        instance_count = 1
        ip_prefix = "10.0.0.0"  # ACI BD Subnet Prefix
        ip_offset = 10 # Number of IPs to skip from prefix, incremented per count
        ip_masklength = 24
        ip_gateway = "10.0.0.1"
      }
      db = {
        tier = "db" # EPG name
        instance_name = "hrapp1-db"
        instance_count = 1
        ip_prefix = "10.0.0.0"  # ACI BD Subnet Prefix
        ip_offset = 20 # Number of IPs to skip from prefix, incremented per count
        ip_masklength = 24
        ip_gateway = "10.0.0.1"
      }
    }
  }
}
