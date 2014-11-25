require 'bundler/setup'
Bundler.setup

require 'fileutils'

require 'git_file'
require 'support/my_file'

module RspecHelper
  module CleanupGitRoot

    def spec_git_root_path
      File::expand_path '../dummy/git_root', __FILE__
    end

    def cleanup
      FileUtils::rm_rf spec_git_root_path
    end

  end
end

RSpec.configure do |config|

  config.mock_with :rspec
  config.color = true
  config.tty = true
  config.fail_fast = true
  config.formatter = :documentation # :progress, :html, :textmate
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include RspecHelper::CleanupGitRoot

  # config.before(:all) do
  #   cleanup
  # end

end
