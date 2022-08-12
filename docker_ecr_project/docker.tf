resource "docker_image" "centos_image" {
  name = "centos:latest"
}

resource "aws_ecr_repository" "project_ecr_repo" {
  name = "project-ecr-repo"
}