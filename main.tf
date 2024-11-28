provider "aws" {
  region = "us-east-1"  # Replace with your desired AWS region.
}
resource "aws_vpc" "region1" {
  cidr_block = var.cidr
}
# internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.region1.id
}

# resource "aws_subnet" "subnets_region1" {
#   count = length(var.subnets_cidr)

#   vpc_id                  = aws_vpc.region1.id
#   cidr_block              = var.subnets_cidr[count.index]
#   availability_zone       = var.region1_availability_zones[0]
#   map_public_ip_on_launch = true

#   tags = {
#     name = "subnet-${count.index}"
#   }
# }

resource "aws_subnet" "subnets_region1" {
  count = length(var.subnets_cidr) * length(var.region1_availability_zones)

  vpc_id                  = aws_vpc.region1.id
  # Assign the CIDR block to each subnet, ensuring unique CIDR per subnet
  cidr_block              = var.subnets_cidr[floor(count.index / length(var.region1_availability_zones))]
  availability_zone       = var.region1_availability_zones[count.index % length(var.region1_availability_zones)]
  map_public_ip_on_launch = true

  tags = {
    name = "subnet-${count.index}-${var.region1_availability_zones[count.index % length(var.region1_availability_zones)]}"
  }
}

# #availability_zone us-east-1b

# resource "aws_subnet" "subnets_region1" {
#   count = length(var.subnets_cidr)

#   vpc_id                  = aws_vpc.region1.id
#   cidr_block              = var.subnets_cidr[count.index]
#   availability_zone       = var.region1_availability_zones[1]
#   map_public_ip_on_launch = true

#   tags = {
#     name = "subnet-${count.index}"
#   }
# }

# nat gateway
resource "aws_eip" "eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw" {

  subnet_id     = aws_subnet.subnets_region1[0].id
  allocation_id = aws_eip.eip.id
}



# security groups for region 1
resource "aws_security_group" "sg_for_all_r1" {
  provider    = aws
  name        = "SG for all"
  description = "This sg is for everything in region 1"
  vpc_id      = aws_vpc.region1.id


  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP access from any IP
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH access from any IP
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Region1-SG"
  }
}


# Nat Gateway 
resource "aws_lb" "alb" {
  name               = "alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_for_all_r1.id]
  subnets            = aws_subnet.subnets_region1[*].id

}

resource "aws_alb_target_group" "target_group" {
  name     = "target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.region1.id
}


resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.target_group.arn
  }
}

resource "aws_lb_target_group_attachment" "target_group_attachment" {
  count            = length(aws_instance.instances)
  target_group_arn = aws_alb_target_group.target_group.arn
  target_id        = aws_instance.instances[count.index].id
  port             = 80
}

