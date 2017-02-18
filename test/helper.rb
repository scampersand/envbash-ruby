require 'minitest/autorun'
require 'minitest/assert_errors'
require 'simplecov'
SimpleCov.start

if ENV['CI'] == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end
