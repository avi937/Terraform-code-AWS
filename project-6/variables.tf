variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name prefix for resources and tags"
  type        = string
  default     = "ecs-fargate-microservice"
}

variable "container_image" {
  description = "Docker image for the microservice"
  type        = string
  default     = "nginxdemos/hello"
}

variable "container_port" {
  description = "Port exposed by the container application"
  type        = number
  default     = 80
}

variable "desired_count" {
  description = "Number of container tasks to run for high availability"
  type        = number
  default     = 2
}
