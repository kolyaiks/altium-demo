locals {
  vpc_cidr = "192.168.0.0/16"
  public_subnet_cidrs = [
    "192.168.1.0/24",
    "192.168.2.0/24",
    "192.168.3.0/24"
  ]
  private_subnet_cidrs = [
    "192.168.11.0/24",
    "192.168.22.0/24",
    "192.168.33.0/24"
  ]
  external_https_cidrs = distinct(concat(
    var.package_repository_cidrs,
    var.secureweb_https_cidrs
  ))
  debug_package_install_bypass_cidrs = var.allow_web_package_install_debug_bypass ? var.debug_package_install_bypass_cidrs : []
}