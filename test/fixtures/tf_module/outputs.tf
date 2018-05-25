output "allow_ssh_ingress_firewall_rule_name" {
  description = "The name of the firewall rule which allows SSH ingress."
  value       = "${module.job.allow_ssh_ingress_firewall_rule_name}"
}

output "allow_data_ingress_to_db_firewall_rule_name" {
  description = "The name of the firewall rule which allows data ingress to the database."
  value       = "${module.job.allow_data_ingress_to_db_firewall_rule_name}"
}

output "job_name" {
  description = "The name of the job compute instance."
  value       = "${module.job.name}"
}

output "network_name" {
  description = "The name of the network in which resources are deployed."
  value       = "${module.network.name}"
}
