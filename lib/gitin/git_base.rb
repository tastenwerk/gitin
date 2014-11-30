module Gitin
  module GitBase

    def directory
      @directory.sub(/^\//,'')
    end

    def path
      File.join( @directory, @filename ).sub(/^\.\//,'').sub(/^\//,'')
    end

    def absolute_path
      File.join( @repo.path, path )
    end

    def save
      create_directory
      File.open(absolute_path, 'w'){ |f| f.write content }
      @repo.git.add absolute_path
    end

    def as_json(options)
      { 
        id: path,
        path: path,
        filename: filename,
        absolute_path: absolute_path,
        directory: directory,
        content: content,
        size: File::size(absolute_path),
        created_at: File::new(absolute_path).ctime,
        updated_at: File::new(absolute_path).mtime
      }
    end

    private

    def create_directory
      return if File.exists?( File.dirname(absolute_path) )
      FileUtils.mkdir_p( File.dirname(absolute_path) )
    end


  end
end
