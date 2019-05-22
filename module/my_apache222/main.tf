provider "aws" {
  access_key = "${var.accesskey}"
  secret_key = "${var.secretkey}"
  region     = "us-east-1"
}

resource "aws_internet_gateway" "gw1" {
  vpc_id = "${aws_vpc.first_terrafor.id}"

  tags = {
    Name = "IG_1"
  }
}

resource "aws_instance" "webu" {
    ami = "ami-0a313d6098716f372"
    subnet_id = "${aws_subnet.sub_1.id}"
    instance_type = "t2.micro"
    key_name = "chefrg"
    associate_public_ip_address = "true"
    vpc_security_group_ids = ["${aws_security_group.sg_1.id}"]

    
  provisioner "chef" {

    environment     = "kalyan"
    run_list        = ["my_apache222::tomcat_install"]
    node_name       = "niharika"
    server_url      = "https://manage.chef.io/organizations/devqtops/"
    recreate_client = true
    user_name       = "kalyanraj"
    user_key        = "${file("./module/my_apache222/kalyanraj.pem")}"
    version         = "14.10.9"
    # If you have a self signed cert on your chef server change this to :verify_none
    ssl_verify_mode = ":verify_none"
  }
  connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = "${file("./module/my_apache222/chefrg.pem")}"
  }
}

resource "aws_vpc" "first_terrafor" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "first_terraform"
    }
}
resource "aws_subnet" "sub_1" {
  vpc_id     = "${aws_vpc.first_terrafor.id}"
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "sub_1"
  }
}

resource "aws_route_table" "vpc1_rt" {
  vpc_id     = "${aws_vpc.first_terrafor.id}"
  route = {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.gw1.id}"
  }
  tags = {
      Name = "rt_1"
  }
}


resource "aws_route_table_association" "subass_1" {
    route_table_id = "${aws_route_table.vpc1_rt.id}"
    subnet_id = "${aws_subnet.sub_1.id}"
}


resource "aws_security_group" "sg_1" {
  vpc_id = "${aws_vpc.first_terrafor.id}"
  name = "sg_1"
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "apacheip_kalyan" {
  value = "${aws_instance.webu.public_ip}"
}
