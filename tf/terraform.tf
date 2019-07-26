terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "benwhite"

    workspaces {
      name = "netlight"
    }
  }
}
