module "tfc_remote_state" {
  source = "../_modules/tfc_remote_state"

  workspaces = ["onpremise-vpc"]
}

locals {
  vpc_outputs = module.tfc_remote_state.outputs["onpremise-vpc"]
}
