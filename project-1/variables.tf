## Region Variable
variable "aws_region" {
    description = "The AWS Region where the resources will be deployed"
    type = string
    default = "ap-south-1"
}

## Instance Size Variable

variable "instance_type" {
    description = "EC2 instance type"
    type = string
    default = "t3.micro"  
}

## Instance Name Tag

variable "instance_name" {
    description = "Instance-Name"
    type = string 
    default = "Instance-001"
}

/* Code Explanation

variable "name" { ... }: Defines a placeholder.
type = string: Ensures only text can be passed (avoids bugs).
default = "...": A fallback value if no custom value is provided.
*/