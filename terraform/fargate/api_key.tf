resource "random_password" "api_key" {
  length      = 24
  min_upper   = 4
  min_numeric = 4
  special     = false
}
