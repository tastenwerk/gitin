module Gitin
  class GitFile

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
      @content = ''
      if options[:content]
        @content = options[:content]
      elsif File.exists?( absolute_path )
        @content = File.open( absolute_path, 'r' ).read
      end
    end

    # returns if current file is up to date
    # with git repository
    #
    def clean?
      @repo.changes.each do |change|
        return false if change.path == path
      end
      true
    end

    # commits the current file to the repository (ignoring other changes)
    #
    def commit(msg)
      @repo.git.add( path )
      @repo.git.commit(msg)
    end

    def delete
      File.delete( absolute_path )
      if Dir.glob( File.dirname( absolute_path ) ).size < 1
        File.open( File.dirname( absolute_path ) + '/.gitkeep', 'w' )
      end
      true
    end

  end
end
