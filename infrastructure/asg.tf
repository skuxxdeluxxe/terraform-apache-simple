module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 4.0"

  # Autoscaling group
  name = "webserver-asg"

  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  vpc_zone_identifier       = tolist(aws_subnet.public.*.id)
  target_group_arns         = [aws_alb_target_group.loadbalancer-target-group.id]
  image_id                  = var.ami
  instance_type             = "t2.micro"

  # Launch Counfiguration
  lt_name = "apache-asg-lt"

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update
              sudo yum install -y httpd
              sudo chkconfig httpd on
              sudo service httpd start
              echo "<h1>Hello World!</h1>" | sudo tee /var/www/html/index.html
            EOF

  use_lc    = true
  create_lc = true

  security_groups = [aws_security_group.webserver-sg.id]
  key_name        = var.key_name

  tags = [
    {
      key                 = "Environment"
      value               = "dev"
      propagate_at_launch = true
    }
  ]
}
