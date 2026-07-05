resource "aws_launch_template" "web" {
  name_prefix            = "${var.company_name}-web-"
  image_id               = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.web_instance_type
  update_default_version = true

  vpc_security_group_ids = [aws_security_group.ec2.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -e
    cat >/etc/yum.repos.d/${var.company_name}-app.repo <<'REPO'
    [${var.company_name}-app]
    name=${var.company_name} application package repository
    baseurl=${var.package_repository_url}
    enabled=1
    gpgcheck=0
    REPO

    package_installed_from_required_repo=false
    if yum --disablerepo='*' --enablerepo='${var.company_name}-app' install -y ${var.web_app_package_name}; then
      package_installed_from_required_repo=true
    fi

    if [ "$package_installed_from_required_repo" != "true" ]; then
      echo "Package install from ${var.package_repository_url} failed."
      if [ "${var.allow_web_package_install_debug_bypass}" != "true" ]; then
        echo "Debug bypass is disabled; application service will not start."
        exit 1
      fi

      echo "DEBUG BYPASS ENABLED: starting debug web service even though required package was not installed from ${var.package_repository_url}."
      yum --disablerepo='${var.company_name}-app' install -y ${var.web_app_service_name}
    fi

    systemctl enable --now ${var.web_app_service_name}
    echo "<h1>Hello from ${var.company_name} ALB demo - $(date)</h1>" > /var/www/html/index.html
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.company_name}-web-instance"
    }
  }
}

resource "aws_autoscaling_group" "web" {
  name                      = "${var.company_name}-web-asg"
  max_size                  = 1
  min_size                  = 1
  desired_capacity          = 1
  health_check_grace_period = 60
  health_check_type         = "EC2"
  vpc_zone_identifier       = module.vpc.private_subnets

  launch_template {
    id      = aws_launch_template.web.id
    version = aws_launch_template.web.latest_version
  }

  target_group_arns = [aws_lb_target_group.this.arn]

  tag {
    key                 = "Name"
    value               = "${var.company_name}-web-asg"
    propagate_at_launch = true
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 0
    }
  }
}

resource "aws_instance" "mysql" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.mysql_instance_type
  subnet_id              = module.vpc.private_subnets[0]
  vpc_security_group_ids = [aws_security_group.mysql.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -e
    yum update -y
    yum install -y mariadb-server
    systemctl start mariadb
    systemctl enable mariadb
    mysql -e "CREATE DATABASE IF NOT EXISTS ${var.company_name}_db;"
  EOF
  )

  tags = {
    Name = "${var.company_name}-mysql-instance"
  }
}
