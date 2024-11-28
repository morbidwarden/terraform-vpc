variable "cidr" {
  default = "10.0.0.0/16"
}
variable "subnets_cidr" {
  default = ["10.0.10.0/24","10.0.20.0/24","10.0.30.0/24"]
}
variable "region1_availability_zones" {
  default = ["us-east-1a", "us-east-1b"]
}
variable "ami_id_r1" {
  default = "ami-0866a3c8686eaeeba"
}
variable "instance_type" {
  default = "t2.micro"
}
