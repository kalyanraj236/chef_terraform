module "my_apache" {
  source = "./module/my_apache222"
  accesskey = "${var.accesskey}"
  secretkey = "${var.secretkey}"
  
}

output "appacheip" {
  value = "${module.my_apache.apacheip_kalyan}"
}

