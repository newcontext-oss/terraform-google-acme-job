# frozen_string_literal: true

allow_ssh_ingress_firewall_rule_name = attribute "allow_ssh_ingress_firewall_rule_name", {}
allow_data_ingress_to_db_firewall_rule_name = attribute "allow_data_ingress_to_db_firewall_rule_name", {}
job_name = attribute "job_name", {}
network_name = attribute "network_name", {}

control "instance" do
  describe "job" do
    subject do
      command "gcloud compute instances describe #{job_name} --zone us-west1-a"
    end

    specify "should block project SSH keys" do
      expect(subject.stdout).to match /key: block-project-ssh-keys.*value: 'TRUE'/m
    end

    specify "should be configured with an SSH key" do
      expect(subject.stdout).to match /key: sshKeys/
    end

    specify "should be configured with a startup script" do
      expect(subject.stdout).to match /key: startup-script/
    end

    specify "should be running" do
      expect(subject.stdout).to match /status: RUNNING/
    end

    specify "should be tagged as a job" do
      expect(subject.stdout).to match /tags:.*items:.*- job/m
    end

    specify "should be labeled as a job" do
      expect(subject.stdout).to match /labels:.*name: job/m
    end
  end
end

control "firewall rules" do
  describe "allow SSH ingress to job" do
    subject do
      command "gcloud compute firewall-rules describe #{allow_ssh_ingress_firewall_rule_name}"
    end

    specify "should allow TCP traffic on port 22" do
      expect(subject.stdout).to match /allowed:.*- IPProtocol: tcp.*ports:.*- '22'/m
    end

    specify "should be directed as ingress" do
      expect(subject.stdout).to match /direction: INGRESS/
    end

    specify "should be configured on the expected network" do
      expect(subject.stdout).to match /network:.*global\/networks\/#{network_name}/
    end

    specify "should have the lowest priority" do
      expect(subject.stdout).to match /priority: 999/
    end

    specify "should target any instance tagged as a job" do
      expect(subject.stdout).to match /targetTags:.*- job/m
    end
  end

  describe "allow data ingress to database" do
    subject do
      command "gcloud compute firewall-rules describe #{allow_data_ingress_to_db_firewall_rule_name}"
    end

    specify "should allow TCP traffic on port 28015" do
      expect(subject.stdout).to match /allowed:.*- IPProtocol: tcp.*ports:.*- '28015'/m
    end

    specify "should be directed as ingress" do
      expect(subject.stdout).to match /direction: INGRESS/
    end

    specify "should be configured on the expected network" do
      expect(subject.stdout).to match /network:.*global\/networks\/#{network_name}/
    end

    specify "should have the second lowest priority" do
      expect(subject.stdout).to match /priority: 998/
    end

    specify "should source instances tagged as a job" do
      expect(subject.stdout).to match /sourceTags:.*- job/m
    end

    specify "should target instances tagged as a database" do
      expect(subject.stdout).to match /targetTags:.*- db/m
    end
  end
end
