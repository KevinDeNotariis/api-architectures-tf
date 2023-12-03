resource "aws_ssm_parameter" "replace_strings_map" {
  name = "/${var.identifier}/${var.environment}/${random_id.this.hex}/replace-strings-map"
  type = "String"
  value = jsonencode({
    ABN       = "ABN AMRO"
    ING       = "ING BANK"
    Rabo      = "Rabobank"
    Triodos   = "Triodos Bank"
    Volksbank = "de Volksbank"
  })

  lifecycle {
    ignore_changes = [value]
  }
}
