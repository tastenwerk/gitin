module Gitin
  class GitDirectory

    attr_accessor :filename, :path, :content

    # initializes a new GitFile
    # if no content is given and the file is found in the
    # repo, the content will be read and loaded into @content
    #
    def initialize( repo, options )
      @repo = repo
      @filename = options[:filename]
      @directory = options[:directory]
    end

    def path
      File.join( @directory, @filename ).sub(/^\.\//,'')
    end

    def absolute_path
      File.join( @repo.path, path )
    end

    def save
      create_directory
      File.open(absolute_path, 'w'){ |f| f.write content }
      @repo.git.add absolute_path
    end

    private

    def create_directory
      return if File.exists?( File.dirname(absolute_path) )
      FileUtils.mkdir_p( File.dirname(absolute_path) )
    end

  end
end
