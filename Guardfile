# frozen_string_literal: true

# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'rspec', cli: '--color' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/parceira/(.+)\.rb$}) { |m| "spec/parceira/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb') { 'spec' }
end
