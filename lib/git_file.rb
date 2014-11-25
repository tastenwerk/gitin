require "git_file/version"

require 'fileutils'
require 'git'

module GitFile

  def self.included(base)
    attr_accessor :filename, :content, :parent
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

    def create( attributes )
      f = new( attributes )
      f.save
      f
    end

    def git
      @@git
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
      File.open File.join( @@root_path,'.gitignore'), 'w'
      @@git.add
      @@git.commit 'initial commit'
    end

  end

  def initialize(attributes)
    raise StandardError, "filename must be given" unless attributes.has_key?(:filename)
    raise StandardError, "filename can't be blank" if attributes[:filename].empty?
    @filename = attributes[:filename]
    @content = attributes[:content] if attributes.has_key?(:content)
  end

  def save
    raise StandardError, "missing root (set with git_root in #{self.name})" unless self.class.git_root
    File.open(absolute_path, 'w'){ |f| f.write content }
    self.class.git.add absolute_path
  end

  def save!
    save && commit('system commit')
  end

  def commit( msg )
    self.class.git.commit msg
  end

  def relative_path
    File.join( path, filename )
  end

  def absolute_path
    File.join( self.class.git_root, relative_path )
  end

  def children
  end

  def path
    @path || ''
  end

end
