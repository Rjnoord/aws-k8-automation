resource "aws_instance" "web" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id = aws_subnet.k8-public-subnet.id
  associate_public_ip_address = true
key_name = "k8-key-pair"
vpc_security_group_ids = [aws_security_group.web-sg.id]

  tags = {
    Name = "Ansible-Kubernetes-server"
  }
}

resource "aws_vpc" "K8-Vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    name = "k8-vpc"
  }
}


resource "aws_subnet" "k8-public-subnet" {
  vpc_id = aws_vpc.K8-Vpc.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true
  
}

resource "aws_internet_gateway" "k8-igw" {
  vpc_id = aws_vpc.K8-Vpc.id
  tags = {
    name= "k8-igw"
  }
}

resource "aws_route_table" "k8-route-table" {
  vpc_id = aws_vpc.K8-Vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.k8-igw.id
  }
  tags = {
    name = "public-route-table"
  }
}


resource "aws_route_table_association" "k8-rta" {
  subnet_id = aws_subnet.k8-public-subnet.id
  route_table_id = aws_route_table.k8-route-table.id

}
resource "aws_security_group" "web-sg" {
  name        = "web-security-group"
  description = "Allow SSH and HTTP"
  vpc_id = aws_vpc.K8-Vpc.id
  

  ingress {
    description = "SSH"

    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"

    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "KubernetesNodes"

    from_port  = 30080
    to_port    = 30080
    protocol   = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}


