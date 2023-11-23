# # ECSクラスタ
# resource "aws_ecs_culuster" "go-nginx-cluster" {
#   name = "go-nginx-sample-cluster"
# }

# # タスク定義(Nginx)
# resource "aws_ecs_task_definition" "nginx-task" {
#   family =  "nginx"
#   cpu = "256"
#   memory =  "512"
#   network_mode = "awsvpc"
#   requires_compatibilities = ["FAGATE"]
#   container_definitions = file("./nginx_container_definitions.json")
# }

# # ECSサービス(Nginx)
# resource "aws_ecs_service" "nginx-service" {
#   name = "nginx-service"
#   cluster = aws_ecs_culuster.go-nginx-sample-cluster.arn
#   task_definition = aws_ecs_task_definition.nginx-task.arn
#   desired_count = 1
#   launch_type = "FARGATE"
#   platform_version = "1.3.0"
#   health_check_grace_period_seconds = 60

#   network_configuration {
#     assign_public_ip = false
#     security_groups =  

#     subnets = [
#       aws_subnet.aws_subnet.sample-subnet-private01
#     ]

    
#   }

#   load_balancer {
#     target_group_arn = aws_lb_target_group.example.arn
#     container_name =  "nginx"
#     container_port =  80
#   }

#   lifecycle {
#     ignore_changes = [task_definition]
#   }
# }

# # TODO: セキュリティグループのモジュール化
# # TODO: ALBの作成
