variable "region" {
  type    = string
  default = "ap-northeast-2"
}

variable "priv_ip" {
  description = "customed private ip for instance"
  type        = string
}

variable "host_name" {
  description = "customed hostname for instance"
  type        = string
}