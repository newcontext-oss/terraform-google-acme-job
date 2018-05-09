# frozen_string_literal: true

control "instance" do
  describe command('gcloud compute instances describe job') do
    its('stdout') { should match (/name: job/) }
    its('stdout') { should match (/key: block-project-ssh-keys.*value: 'TRUE'/m) }
    its('stdout') { should match (/- key: sshKeys/) }
    its('stdout') { should match (/- key: startup-script/) }
    its('stdout') { should match (/status: RUNNING/) }
    its('stdout') { should match (/tags:.*items:.*- job/m) }
    its('stdout') { should match (/zone:.*zones\/us-west1-a/) }
    its('stdout') { should match (/labels:.*name: job/m) }
  end
end

control "firewall" do
  describe command('gcloud compute firewall-rules describe job-tcp22-ingress') do
    its('stdout') { should match (/allowed:.*- IPProtocol: tcp.*ports:.*- '22'/m) }
    its('stdout') { should match (/direction: INGRESS/) }
    its('stdout') { should match (/network:.*global\/networks\/test-org/) }
    its('stdout') { should match (/priority: 999/) }
    its('stdout') { should match (/targetTags:.*- job/m) }
  end

  describe command('gcloud compute firewall-rules describe job-to-db-tcp28015-ingress') do
    its('stdout') { should match (/allowed:.*- IPProtocol: tcp.*ports:.*- '28015'/m) }
    its('stdout') { should match (/direction: EGRESS/) }
    its('stdout') { should match (/network:.*global\/networks\/test-org/) }
    its('stdout') { should match (/priority: 998/) }
    its('stdout') { should match (/sourceTags:.*- job/m) }
    its('stdout') { should match (/targetTags:.*- db/m) }
  end
end
