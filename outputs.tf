output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.this.dns_name
}

output "alb_custom_domain_name" {
  description = "Custom domain name pointing to the ALB"
  value       = aws_route53_record.alb.fqdn
}

output "mysql_instance_id" {
  description = "ID of the MySQL EC2 instance"
  value       = aws_instance.mysql.id
}

output "mysql_private_ip" {
  description = "Private IP of the MySQL EC2 instance"
  value       = aws_instance.mysql.private_ip
}

output "web_package_install_debug_bypass_enabled" {
  description = "Whether web bootstrap may fall back to system repositories when package_repository_url is unavailable."
  value       = var.allow_web_package_install_debug_bypass
}
