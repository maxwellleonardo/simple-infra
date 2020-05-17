data "http" "workstation-external-ip" {
  url = "https://ipinfo.io/ip"
}

locals {
  workstation-external-cidr = "${chomp(data.http.workstation-external-ip.body)}/32"
}

