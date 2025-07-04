
resource "aws_instance" "k6_instance" {
  ami                         = data.aws_ssm_parameter.ami.value
  instance_type               = var.MyInstanceType
  key_name                    = var.KeyName
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  private_ip                  = "192.168.1.101"
  vpc_security_group_ids = [aws_security_group.k6_security_group.id]

  tags = {
    Name = "k6-instance"
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    delete_on_termination = true
  }

  user_data = <<-EOF
   sudo gpg -k && /
   sudo gpg --no-default-keyring --keyring /usr/share/keyrings/k6-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69 && /
   echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list && /
   sudo apt-get update && /
   sudo apt-get install k6
  EOF
}

resource "aws_security_group" "k6_security_group" {

  vpc_id = module.vpc.vpc_id

  name        = "k6-sec-group"
  description = "Security group for K6 Host"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 5665
    to_port = 5665
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "K6-SG"
  }
}
