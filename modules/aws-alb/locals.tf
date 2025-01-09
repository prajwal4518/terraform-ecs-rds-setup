locals {
  alb_name = "${var.tags["environment"]}-${var.tags["project"]}"
}