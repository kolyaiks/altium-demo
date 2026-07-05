variable "region" {
  default = "us-east-1"
}

variable "company_name" {
  default = "altium"
}

variable "domain_name" {
  description = "Domain name for the wildcard SSL certificate"
  type        = string
  default     = "niks.cloud"
}

variable "allowed_inbound_cidr_blocks" {
  description = "Finite list of CIDR blocks allowed to access the ALB. Do not use 0.0.0.0/0."
  type        = list(string)

  validation {
    condition = (
      length(var.allowed_inbound_cidr_blocks) > 0 &&
      !contains(var.allowed_inbound_cidr_blocks, "0.0.0.0/0") &&
      !contains(var.allowed_inbound_cidr_blocks, "::/0")
    )
    error_message = "allowed_inbound_cidr_blocks must be a non-empty finite allowlist and cannot include 0.0.0.0/0 or ::/0."
  }
}

variable "secureweb_https_cidrs" {
  description = "Explicit secureweb.com CIDRs the web EC2 instances need to reach over HTTPS."
  type        = list(string)
  default = [
    "98.84.224.111/32", # secureweb.com
    "18.208.88.157/32"  # secureweb.com
  ]

  validation {
    condition = (
      length(var.secureweb_https_cidrs) > 0 &&
      !contains(var.secureweb_https_cidrs, "0.0.0.0/0") &&
      !contains(var.secureweb_https_cidrs, "::/0")
    )
    error_message = "secureweb_https_cidrs must be a non-empty finite allowlist and cannot include 0.0.0.0/0 or ::/0."
  }
}

variable "package_repository_url" {
  description = "HTTPS yum repository URL that hosts the application package required at startup."
  type        = string
  default     = "https://example.com/repo/$releasever/$basearch"
}

variable "package_repository_cidrs" {
  description = "Explicit example.com/package repository CIDRs the EC2 instances can reach over HTTPS during bootstrap."
  type        = list(string)
  default = [
    "104.20.23.154/32", # example.com
    "172.66.147.243/32" # example.com
  ]

  validation {
    condition = (
      length(var.package_repository_cidrs) > 0 &&
      !contains(var.package_repository_cidrs, "0.0.0.0/0") &&
      !contains(var.package_repository_cidrs, "::/0")
    )
    error_message = "package_repository_cidrs must be a non-empty finite allowlist and cannot include 0.0.0.0/0 or ::/0."
  }
}

variable "web_app_package_name" {
  description = "Application package installed from package_repository_url before the web service starts."
  type        = string
  default     = "httpd"
}

variable "web_app_service_name" {
  description = "Systemd service started after the web application package is installed."
  type        = string
  default     = "httpd"
}

variable "allow_web_package_install_debug_bypass" {
  description = "Debug-only backdoor that installs the web package from enabled system repositories if package_repository_url is unavailable."
  type        = bool
  default     = false
}

variable "debug_package_install_bypass_cidrs" {
  description = "Debug-only outbound CIDRs used when allow_web_package_install_debug_bypass is true so system repositories can install the web package."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "web_instance_type" {
  description = "Instance type for the web EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "mysql_instance_type" {
  description = "Instance type for the MySQL EC2 instance"
  type        = string
  default     = "t2.micro"
}
