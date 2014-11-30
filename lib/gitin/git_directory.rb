module Gitin
  class GitDirectory

    include Gitin::GitBase

    attr_accessor :filename, :content

    # initializes a new GitFile
    # if no content is given and the file is found in the
    # repo, the content will be read and loaded into @content
    #
    def initialize( repo, options )
      @repo = repo
      @filename = options[:filename]
      @directory = options[:directory]
    end

  end
end
