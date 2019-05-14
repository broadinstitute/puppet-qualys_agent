require 'spec_helper'
describe 'qualys_agent' do
  context 'with default values for all parameters' do
    it { should contain_class('qualys_agent') }
  end
end
