require 'spec_helper'
describe 'role_xenocanto' do
  context 'with default values for all parameters' do
    it { should contain_class('role_xenocanto') }
  end
end
