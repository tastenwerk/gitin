require "git_file/version"

require 'fileutils'
require 'git'

module GitFile

  def self.included(base)
    attr_accessor :filename, :parent, :size, :directory
    base.extend ClassMethods
  end

  module ClassMethods

    def git_file?
      true
    end

    def git_config( key, value=nil )
      @@g_config ||= {}
      return @@g_config[key] unless value
      @@g_config[key] = value
    end

    def git_root(root_path=nil,force_create=nil)
      @@root_path ||= nil
      @@g_config ||= {}
      return @@root_path unless root_path
      @@root_path = root_path
      create_directory(force_create)
      init_git
      @@root_path
    end

    def create( type, attributes=nil )
      f = new( type, attributes )
      f.save
      f
    end

    def git
      @@git
    end

    def changes
      arr = []
      @@git.status.each{ |f| arr << f if f.type =~ /A|D/ }
      arr
    end

    def clean?
      changes.size == 0
    end
  
    def commit( msg )
      git.commit msg
    end

    def init( file, path )
      fn = File.join( path, file )
      cleanpath = path.sub(@@root_path,'')
      if File.directory?(fn)
        return new( :directory, filename: file, path: cleanpath )
      end
      new( filename: file, directory: cleanpath, content: File.open(fn,'r').read, size: File.size(fn) )
    end

    def list(path='')
      path = File.join( @@root_path, path )
      result = []
      Dir.foreach(path) do |file|
        next if file == '.' || file == '..' || file == '.git' || file == '.gitignore' || file == '.gitkeep'
        result << init( file, path )
      end
      result
    end

    def find( path )
      result = []
      Dir.glob( "#{@@root_path}/**/#{path}") do |file|
        result << init( File::basename(file), File::dirname(file) )
      end
      result
    end

    def findOne( path )
      result = find( path )
      result.first
    end

    private

    def create_directory(force_create)
      if !File.exists? @@root_path
        if force_create == :create
          FileUtils::mkdir_p(@@root_path)
        else
          raise StandardError, "path #{@@root_path} does not exist. Use force_create option to force it's creation or create by hand"
        end
      end
    end

    def init_git
      @@git = Git.init @@root_path
      return if @@git.branches.size > 0
      @@g_config.each_pair{ |k,v| @@git.config k, v }
      gitignore = File.join( @@root_path,'.gitignore')
      File.open gitignore, 'w'
      @@git.add gitignore
      @@git.commit 'initial commit'
    end

  end

  def initialize(type,attributes=nil)
    unless attributes
      attributes = type
      type = nil
    end
    raise StandardError, "filename must be given" unless attributes.has_key?(:filename)
    raise StandardError, "filename can't be blank" if attributes[:filename].empty?
    @filename = attributes[:filename]
    @directory = ''
    if attributes.has_key?(:directory)
      @directory = attributes[:directory] 
      if !File.exists?( File::join( self.class.git_root, @directory ) ) ||
        !File.directory?( File::join( self.class.git_root, @directory ) )
        raise StandardError, "not a directory #{@directory}"
      end
    end
    @content = attributes.has_key?(:content) ? attributes[:content] : nil
    @type = type.to_s || File::extname(@filename).sub('.','')
  end

  def directory?
    @type == 'directory'
  end

  def save
    raise StandardError, "missing root (set with git_root in #{self.name})" unless self.class.git_root
    if @type == 'directory'
      FileUtils.mkdir( absolute_path )
      File.open("#{absolute_path}/.gitkeep", 'w')
      self.class.git.add "#{absolute_path}/.gitkeep"
    else
      File.open(absolute_path, 'w'){ |f| f.write content }
      self.class.git.add absolute_path
    end
  end

  def save!
    save && commit('system commit')
  end

  def commit( msg )
    self.class.git.commit msg
  end

  def path
    File.join( directory, filename ).sub(/^\//, '')
  end

  def absolute_path
    File.join( self.class.git_root, path )
  end

  def content=(content)
    @content = content unless directory?
  end

  def content
    return @content unless directory?
    self.class.list( path )
  end

  def deleted?
    @deleted || false
  end

  def delete
    puts "deleting #{absolute_path}"
    FileUtils.rm_rf( absolute_path )
    @deleted = true
  end

end
