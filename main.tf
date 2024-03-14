# Configure the AliCloud Provider
provider "alicloud" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

# Create a VPC
resource "alicloud_vpc" "main" {
  vpc_name   = "TestVPC"
  cidr_block = var.vpc_cidr_block
}

# Create a public subnet
resource "alicloud_vswitch" "public" {
  vpc_id       = alicloud_vpc.main.id
  vswitch_name = "PublicSubnet"
  cidr_block   = var.public_subnet_cidr
  zone_id      = var.availability_zone
  depends_on   = [alicloud_vpc.main]
}

# Create a private subnet
resource "alicloud_vswitch" "private" {
  vpc_id       = alicloud_vpc.main.id
  vswitch_name = "PrivateSubnet"
  cidr_block   = var.private_subnet_cidr
  zone_id      = var.availability_zone
  depends_on   = [alicloud_vpc.main]
}


# Create ipv4 gateway for internet (inbound and outbound traffic)
resource "alicloud_vpc_ipv4_gateway" "internet" {
  ipv4_gateway_name = "internet"
  vpc_id            = alicloud_vpc.main.id
  enabled           = "true"
}

# Create a route table 
resource "alicloud_route_table" "PublicRT" {
  vpc_id           = alicloud_vpc.main.id
  route_table_name = "PublicRT"
}

# Create route entry to ipv4 gateway in the route table
resource "alicloud_route_entry" "ToInternet" {
  route_table_id        = alicloud_route_table.PublicRT.id
  destination_cidrblock = "0.0.0.0/0"
  nexthop_type          = "Ipv4Gateway"
  nexthop_id            = alicloud_vpc_ipv4_gateway.internet.id
}

# Attach the route table to the public subnet
resource "alicloud_route_table_attachment" "attach-to-public-subnet" {
  vswitch_id     = alicloud_vswitch.public.id
  route_table_id = alicloud_route_table.PublicRT.id
}

# Frontend Machine with Public IP
resource "alicloud_instance" "frontend" {

  availability_zone    = var.availability_zone
  security_groups      = alicloud_security_group.frontend_sg.*.id
  instance_type        = var.instance_type
  system_disk_category = "cloud_efficiency"
  system_disk_name     = "Sysdisk"
  system_disk_size     = var.disk_size
  image_id             = var.image_id
  instance_name        = "Frontend"
  vswitch_id           = alicloud_vswitch.public.id
  # attach a public ip to the ecs instance
  internet_max_bandwidth_out = 1
  key_name                   = alicloud_ecs_key_pair.publickey.key_pair_name


  provisioner "file" {
    source      = "frontend-config.sh"
    destination = "frontend-config.sh"

    connection {
      type        = "ssh"
      user        = "root"
      private_key = file("./id_rsa")
      host        = self.public_ip
    }

  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x frontend-config.sh", # Ensure script is executable
      "./frontend-config.sh"          # Run the script
    ]

    connection {
      type        = "ssh"
      user        = "root"
      private_key = file("./id_rsa")
      host        = self.public_ip
    }
  }
}

# Backend Machine with Public IP
resource "alicloud_instance" "backend" {

  availability_zone    = var.availability_zone
  security_groups      = alicloud_security_group.backend_sg.*.id
  instance_type        = var.instance_type
  system_disk_category = "cloud_efficiency"
  system_disk_name     = "Sysdisk"
  system_disk_size     = var.disk_size
  image_id             = var.image_id
  instance_name        = "Backend"
  vswitch_id           = alicloud_vswitch.public.id
  # attach a public ip to the ecs instance
  internet_max_bandwidth_out = 1
  key_name                   = alicloud_ecs_key_pair.publickey.key_pair_name


  provisioner "file" {
    source      = "backend-config.sh"
    destination = "backend-config.sh"

    connection {
      type        = "ssh"
      user        = "root"
      private_key = file("./id_rsa")
      host        = self.public_ip
    }

  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x backend-config.sh", # Ensure script is executable
      "./backend-config.sh"          # Run the script
    ]

    connection {
      type        = "ssh"
      user        = "root"
      private_key = file("./id_rsa")
      host        = self.public_ip
    }
  }

}

# Security Group for frontend machine
resource "alicloud_security_group" "frontend_sg" {
  name   = "frontend_sg"
  vpc_id = alicloud_vpc.main.id
}

# frontend_sg rules
resource "alicloud_security_group_rule" "ssh-frontend" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "22/22"
  security_group_id = alicloud_security_group.frontend_sg.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "http-frontend" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "80/80"
  security_group_id = alicloud_security_group.frontend_sg.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "node-frontend" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "3001/3001"
  security_group_id = alicloud_security_group.frontend_sg.id
  cidr_ip           = "0.0.0.0/0"
}


# Security Group for backend machine
resource "alicloud_security_group" "backend_sg" {
  name   = "backend_sg"
  vpc_id = alicloud_vpc.main.id
}

# backend_sg rules
resource "alicloud_security_group_rule" "ssh-backend" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "22/22"
  security_group_id = alicloud_security_group.backend_sg.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "http-backend" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "80/80"
  security_group_id = alicloud_security_group.backend_sg.id
  cidr_ip           = "0.0.0.0/0"
}

# Import an existing public key to build alicloud key pair
resource "alicloud_ecs_key_pair" "publickey" {
  key_pair_name = "Admin"
  public_key    = var.public_key
}

# Attach the public key to the ecs instances
resource "alicloud_ecs_key_pair_attachment" "publickey-attach-to-ecs" {
  key_pair_name = alicloud_ecs_key_pair.publickey.key_pair_name
  instance_ids  = [alicloud_instance.frontend.id, alicloud_instance.backend.id]
}

# Create RDS
resource "alicloud_db_instance" "dbinstance" {
  engine             = "MySQL"
  engine_version     = "5.6"
  instance_type      = "rds.mysql.t1.small"
  instance_storage   = "10"
  vswitch_id         = alicloud_vswitch.private.id
  security_group_ids = [alicloud_security_group.backend_sg.id]
}

# Create DB account
resource "alicloud_db_account" "account" {
  db_instance_id   = alicloud_db_instance.dbinstance.id
  account_name     = "testuser"
  account_password = var.dbaccount_password
}

# Create DB
resource "alicloud_db_database" "db" {
  instance_id = alicloud_db_instance.dbinstance.id
  name        = "testdb"
}

# Grant the account access to the db
resource "alicloud_db_account_privilege" "privilege" {
  instance_id  = alicloud_db_instance.dbinstance.id
  account_name = alicloud_db_account.account.account_name
  db_names     = [alicloud_db_database.db.name]
  privilege    = "ReadWrite"
}

# Create db connection
resource "alicloud_db_connection" "connection" {
  instance_id = alicloud_db_instance.dbinstance.id
}

# Confiure Cloud Monitor alarm rule to send an email when CPU utilization is above 50%

# Define an alarm contact group
resource "alicloud_cms_alarm_contact_group" "cpu-group" {
  alarm_contact_group_name = "CPU50"
  contacts                 = [alicloud_cms_alarm_contact.contact-admin.alarm_contact_name]
}

# Define an alarm contact for receiving notifications
resource "alicloud_cms_alarm_contact" "contact-admin" {
  alarm_contact_name = "Admin"
  describe           = "CPU Alarm"
  channels_mail      = "ashraf.salah.salama2014@gmail.com"
  lifecycle {
    ignore_changes = [channels_mail]
  }
}

# Define the CPU utilization alarm
resource "alicloud_cms_alarm" "cpu_alarm" {
  name               = "cpu_utilization_alarm"
  project            = "acs_ecs_dashboard"
  metric             = "cpu_total"
  period             = 300
  contact_groups     = [alicloud_cms_alarm_contact_group.cpu-group.alarm_contact_group_name]
  effective_interval = "00:00-24:00"
  metric_dimensions = jsonencode([
    {
      instanceId = "${alicloud_instance.frontend.id}"
    },
    {
      instanceId = "${alicloud_instance.backend.id}"
    }
  ])

  escalations_critical {
    statistics          = "Average"
    comparison_operator = ">"
    threshold           = 50
    times               = 2
  }
}
