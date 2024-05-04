# Deploying a Fargate service with Terraform
# DO NOT ENABLE THIS UNLESS FOR DEMONSTRATION PURPOSES
# This is expensive! WHY DOES AN ALB COST $20 A MONTH?!

# data "aws_vpc" "default_vpc" {
#   default = true
# }
#
# data "aws_subnets" "default_subnets"  {
#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpc.default_vpc.id]
#   }
# }
#
# resource "aws_iam_policy" "realEstateSTSpolicy" {
#   name        = "real-estate_policy"
#   description = "A test policy"
#   policy      = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": [
#         "ecs:*",
#         "ecr:*"
#       ],
#       "Resource": "*"
#     }
#   ]
# }
# EOF
# }
#
# resource "aws_iam_role" "execution_role" {
#   name = "real-estate_execution_role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Action = "sts:AssumeRole"
#       Effect = "Allow"
#       Principal = {
#         Service = "ecs-tasks.amazonaws.com"
#       }
#     }]
#   })
# }
#
# resource "aws_iam_role_policy_attachment" "execution_role_policy_attach" {
#   role       = aws_iam_role.execution_role.name
#   policy_arn = aws_iam_policy.realEstateSTSpolicy.arn
# }
#
# resource "aws_iam_role" "task_role" {
#   name = "real-estate_task_role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Action = "sts:AssumeRole"
#       Effect = "Allow"
#       Principal = {
#         Service = "ecs-tasks.amazonaws.com"
#       }
#     }]
#   })
# }
#
# resource "aws_iam_role_policy_attachment" "task_role_policy_attach" {
#   role       = aws_iam_role.task_role.name
#   policy_arn = aws_iam_policy.realEstateSTSpolicy.arn
# }
#
# resource "aws_iam_service_linked_role" "ecs" {
#   aws_service_name = "ecs.amazonaws.com"
# }
#
# resource "aws_security_group" "fargate_sg" {
#   name = "real-estate_fargate_sg"
#   description = "Allow inbound traffic"
#
#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   egress {
#     from_port       = 0
#     to_port         = 0
#     protocol        = "-1"
#     cidr_blocks     = ["0.0.0.0/0"]
#   }
# }
#
# resource "aws_ecs_cluster" "fargate_cluster" {
#   name = "real-estate_fargate_cluster"
# }
#
# resource "aws_lb" "fargate_lb" {
#   name               = "realEstateFargateLB"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.fargate_sg.id]
#   subnets            = data.aws_subnets.default_subnets.ids
# }
#
# resource "aws_lb_target_group" "fargate_tg" {
#   name     = "ealEstateFargateTG"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = data.aws_vpc.default_vpc.id
#   target_type = "ip"
# }
#
# resource "aws_lb_listener" "fargate_listener" {
#   load_balancer_arn = aws_lb.fargate_lb.arn
#   port              = 80
#   protocol          = "HTTP"
#
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.fargate_tg.arn
#   }
# }
#
# resource "aws_ecs_service" "fargate_service" {
#   name            = "fargate_service"
#   cluster         = aws_ecs_cluster.fargate_cluster.id
#   task_definition = aws_ecs_task_definition.fargate_task.arn
#   desired_count   = 1
#   launch_type     = "FARGATE"
#
#   network_configuration {
#     assign_public_ip = true
#     subnets          = data.aws_subnets.default_subnets.ids
#     security_groups  = [aws_security_group.fargate_sg.id]
#   }
#
#   load_balancer {
#     target_group_arn = aws_lb_target_group.fargate_tg.arn
#     container_name   = "fargate_app"
#     container_port   = 80
#   }
# }
#
# resource "aws_ecs_task_definition" "fargate_task" {
#   family                   = "fargate_task_family"
#   network_mode             = "awsvpc"
#   requires_compatibilities = ["FARGATE"]
#   cpu                      = "256"  #  .25 vCPU (256)
#   memory                   = "512"  # 0.5  GB   (512)
#   # This is the minimum amount of resources you can allocate to a Fargate task.
#   execution_role_arn       = aws_iam_role.execution_role.arn
#   task_role_arn            = aws_iam_role.task_role.arn
#
#   container_definitions = jsonencode([{
#     name  = "fargate_app"
#     image = "${aws_ecr_repository.realestate_ecr_repo.repository_url}:real-estate-image-15"
#     portMappings = [{
#       containerPort = 80
#       hostPort      = 80
#       protocol      = "tcp"
#     }]
#   }])
# }
#
# resource "aws_route53_record" "fargate_r53_record" {
#   zone_id = data.aws_route53_zone.local_env_nhitroung_com.zone_id
#   name    = "real-estate.fargate.prod.nhitruong.com"
#   type    = "CNAME"
#   ttl     = "300"
#   records = [aws_lb.fargate_lb.dns_name]
# }