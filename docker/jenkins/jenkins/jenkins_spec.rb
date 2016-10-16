require "spec_helper"
require "docker"
require "serverspec"

#Ports on which Jenkins will listen
JENKINS_PORT = 8080
JENKINS_SLAVE_AGENT_PORT = 50000

describe "Dockerfile" do
   before(:all) do
      get_docker_image(__dir__)
   end

   describe 'Dockerfile#config' do
      it 'should expose the Jenkins ports' do
         expect(@image.json['ContainerConfig']['ExposedPorts']).to include("#{JENKINS_PORT}/tcp")
         expect(@image.json['ContainerConfig']['ExposedPorts']).to include("#{JENKINS_SLAVE_AGENT_PORT}/tcp")
      end
   end

   describe command('whoami'), :sudo => false do
      its(:stdout) { should match 'jenkins' }
   end

   describe file('/usr/share/jenkins/ref/plugins/chucknorris.hpi') do
      it { should be_file }
   end

   describe user('jenkins') do
      it { should belong_to_group 'docker' }
   end
end
