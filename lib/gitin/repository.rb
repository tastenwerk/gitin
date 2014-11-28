require 'fileutils'
require 'git'

module Gitin
  class Repository

    attr_accessor :path,
                  :username,
                  :email,
                  :git

    # initialize the repository with:
    #
    # a.) path as string
    # b.) options hash
    #     :path (required), :username, :email
    #
    def initialize( options )
      options = { path: options } if options.is_a?(String)
      @path = options[:path]
      @username = options[:username]
      @email = options[:email]
      init_git
    end

    # returns an array of changed items (GitStatus::StatusFile)
    #
    def changes
      arr = []
      git.status.each{ |f| arr << f if f.type =~ /A|D/ }
      arr
    end

    # returns true or false if there are any uncommitted changes
    # in the repo
    #
    def clean?
      changes.size == 0
    end

    # finds a file by given relative path in the repository
    #
    # e.g.:
    # repo.find( 'myfoler/myfile' )
    # => [ Gitin::GitFile ]
    #
    # repo.find
    # => [ files, on, root, path ]
    #
    # repo.find( 'myfolder/*' )
    # => [ files, within, myfolder ]
    #
    def find( p=nil )
      result = []
      p = get_option_for_find(p)
      Dir.glob( p ) do |full_filename|
        file = full_filename.sub(@path,'')
        if File.directory? full_filename
          result << Gitin::GitDirectory.new( self, filename: File::basename(file), directory: File::dirname(file) )
        else
          result << Gitin::GitFile.new( self, filename: File::basename(file), directory: File::dirname(file) )
        end
      end
      result
    end

    # calls find and returns first object
    #
    def findOne( path )
      find( path ).first
    end

    def create( path, content=nil )
      git_file = build( path, content )
      git_file.save
      git_file
    end

    def build( path, content=nil )
      Gitin::GitFile.new( self, filename: File::basename(path), directory: File::dirname(path), content: content )
    end

    # commit all changes in repository
    #
    def commit( msg )
      git.commit_all msg
    end

    private

    def init_git
      @git = Git.init @path
      git.config 'user.name', @username if @username
      git.config 'user.email', @email if @email
      create_repos if git.branches.size < 1
    end

    def create_repos
      gitignore = File.join( @path, '.gitignore')
      File.open gitignore, 'w'
      git.add gitignore
      git.commit 'initial commit'
    end

    def get_option_for_find(p)
      if p && p.is_a?(Symbol) && p == :recursive
        "#{@path}/**/*"
      elsif p
        "#{@path}/#{p}"
      else
        "#{@path}/*"
      end
    end

  end
end
