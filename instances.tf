resource "aws_instance" "instances" {
  count = length(var.subnets_cidr) * length(var.region1_availability_zones)

  ami           = var.ami_id_r1
  instance_type = var.instance_type
  subnet_id     = aws_subnet.subnets_region1[floor(count.index / length(var.region1_availability_zones))].id
  availability_zone = var.region1_availability_zones[count.index % length(var.region1_availability_zones)]
  vpc_security_group_ids      = [aws_security_group.sg_for_all_r1.id]
  tags = {
    Name = "instance-${count.index / length(var.region1_availability_zones)}-${var.region1_availability_zones[count.index % length(var.region1_availability_zones)]}"
  }
}
