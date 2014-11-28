require 'bundler/setup'
Bundler.setup

require 'fileutils'

require 'gitin'
require 'support/my_file'

module RspecHelper
  module CleanupGitRoot

    def spec_git_path
      File::expand_path '../dummy/git_root', __FILE__
    end

    def cleanup
      FileUtils::rm_rf spec_git_path
    end

    def create_repo
      Gitin::Repository.new(spec_git_path)
    end

    def clean_create_repo
      cleanup
      create_repo
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
