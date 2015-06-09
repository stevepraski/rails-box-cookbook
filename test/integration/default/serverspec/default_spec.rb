require 'spec_helper'

describe 'rails-box-cookbook::default' do
  # Serverspec examples can be found at
  # http://serverspec.org/resource_types.html
  postgres_client = os[:family] == 'redhat' ? 'postgresql93' : 'postgresql-client-9.4'
  it "#{postgres_client} for #{os[:family]} is installed" do
    package(postgres_client).should be_installed
  end
end
