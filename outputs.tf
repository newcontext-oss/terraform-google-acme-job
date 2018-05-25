output "allow_ssh_ingress_firewall_rule_name" {
  description = "The name of the firewall rule which allows SSH ingress."
  value       = "${google_compute_firewall.allow_ssh_ingress.name}"
}

output "allow_data_ingress_to_db_firewall_rule_name" {
  description = "The name of the firewall rule which allows data ingress to the database."
  value       = "${google_compute_firewall.allow_data_ingress_to_db.name}"
}

output "name" {
  description = "The name of the job compute instance."
  value       = "${google_compute_instance.job.name}"
}
