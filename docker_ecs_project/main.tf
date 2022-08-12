data "aws_ecr_repository" "project_ecr_repo" {
  name = "project-ecr-repo"
}

resource "aws_ecs_cluster" "project_cluster" {
  name = "project-cluster"
}

resource "aws_ecs_service" "project_service" {
  name            = "project-service"
  cluster         = aws_ecs_cluster.project_cluster.id
  task_definition = aws_ecs_task_definition.project_task.arn
  launch_type     = "FARGATE"
  desired_count   = 3

  network_configuration {
    subnets          = ["${aws_subnet.public_1.id}", "${aws_subnet.public_2.id}"]
    assign_public_ip = true
  }
}

resource "aws_ecs_task_definition" "project_task" {
  family                   = "project-task"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "project-task",
      "image": "${data.aws_ecr_repository.project_ecr_repo.repository_url}",
      "essential": true,
      "cpu": 256,
      "memory": 512,
      "portMappings": [
        {
          "containerPort": 3000,
          "hostPort": 3000
        }
      ]
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
}

data "aws_iam_policy_document" "ecs-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs-assume-role-policy.json
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}