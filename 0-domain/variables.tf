# Route53 Hosted Zone
variable "route53_zone_name" {
  description = "Name of the domain that you want to route traffic for."
  type        = string
  default     = "jml.lat"
}
