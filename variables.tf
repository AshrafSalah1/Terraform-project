variable "region" {
  default = "us-east-1"
}

variable "availability_zone" {
  default = "us-east-1a"
}

variable "instance_type" {
  default = "ecs.t6-c1m1.large"
}

variable "disk_size" {
  default = 20
}

variable "image_id" {
  default = "ubuntu_22_04_x64_20G_alibase_20231221.vhd"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  default = "10.0.2.0/24"
}

variable "public_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDs5BoEP5bSEjJ04gRbafdUmhZKMoGbTiaz46pUUCktrp3DgLdTyj7A9sUyHjC7IunjpIlAcH4bk3GMW6bJMWysK74BouyMi1udvaj84ZiF8WDUewfFwNekd0IvMFTfeXNJ65y8Qp5Njnma2nm2r6o4HlgMfZMeJDK2N/57JzvM+JPMWbYEdyKE7EBqTnmLwgD0xpZL0Wxo4BjzF7KYccBflvN/BlBmFuab/4+E+9DArTlGFcA14J9xIYVHxcIJvitD0hl0rnmBdpq1yU4mjI5P63xgo101mRETUEM9fjJQpwIj+nFPZ1CiyVyT2SPc6dITp1CBkp42jmzQUFl/gy6h AshrafSalah@Ashraf_Salah"
}

variable "dbaccount_password" {
  default = "XLlyKb1%1i3("
}

variable "access_key" {
  default = "To be replaced"
}

variable "secret_key" {
  default = "To be replaced"
}
