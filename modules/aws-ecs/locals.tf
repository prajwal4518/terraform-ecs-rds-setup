locals {
  ecs_name = "${var.tags["environment"]}-${var.tags["project"]}"
}
