module Gitin
  class GitFile

    attr_accessor :filename, :path, :content

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

    def path
      File.join( @directory, @filename ).sub(/^\.\//,'')
    end

    def directory
      @directory.sub(/^\//,'')
    end

    def absolute_path
      File.join( @repo.path, path )
    end

    def save
      create_directory
      File.open(absolute_path, 'w'){ |f| f.write content }
      @repo.git.add absolute_path
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

    private

    def create_directory
      return if File.exists?( File.dirname(absolute_path) )
      FileUtils.mkdir_p( File.dirname(absolute_path) )
    end

  end
end
