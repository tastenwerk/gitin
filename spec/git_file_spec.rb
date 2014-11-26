require 'spec_helper'

describe GitFile do
  
  context "support/my_file declares a git_file enabled class" do
    
    before(:each){ cleanup }

    it { expect(MyFile.git_file?).to be true}
    it { expect(MyFile.git_root).to be nil}

    context "set git root" do
      before(:each){ MyFile.git_root spec_git_root_path, :create }

      it { expect(MyFile.git_root).to eq(spec_git_root_path) }
    end

    context "set git config" do
      before(:each){ MyFile.git_root spec_git_root_path, :create }

      context "set user email" do
        before { MyFile.git_config 'user.email', 'test@example.com' }
        it { expect( MyFile.git_config 'user.email' ).to eq('test@example.com') }
      end
    end

    context "file system setup" do
      before(:each){ MyFile.git_root spec_git_root_path, :create }

      it "creates a git repository after git_root has been set" do
        expect( File ).to exist(MyFile.git_root+'/.git')
      end

    end

  end

  context "re-opening a git repos" do
    before(:all) do
      cleanup
      MyFile.git_root spec_git_root_path, :create
    end

    it { expect( MyFile.git_root spec_git_root_path, :create ).to eq( spec_git_root_path) }
  end

  context "git operations" do

    before(:all) do
      cleanup
      MyFile.git_root spec_git_root_path, :create
    end

    context "create a git file" do

      let(:file){ MyFile.create filename: 'test.txt', content: 'test' }

      it{ expect( File ).to exist( file.absolute_path ) }

      it{ expect( File.open(file.absolute_path).read ).to eq( file.content ) }

    end

    context "get repository status" do

      it { expect( MyFile.clean? ).to be false }

      it { expect( MyFile.changes.size ).to eq(1) }

    end

    context "commit repository" do

      it { expect( MyFile.commit('msg') ).to include('master')}

      it { expect( MyFile.clean? ).to be true }

      it { expect( MyFile.changes.size ).to eq(0) }

    end

    context "list repository's files" do

      it { expect( MyFile.list ).to be_a(Array) }

      it { expect( MyFile.list.size ).to eq(1) }

      it { expect( MyFile.list.first ).to be_a(MyFile) }

      it { expect( MyFile.list.first.filename).to eq('test.txt') }

    end

    context "create a directory" do

      let(:dir){ MyFile.create( :directory, filename: 'testdir' ) }

      it { expect( dir.directory? ).to be true }

      it { expect( MyFile.list.size ).to eq(2) }

      it { expect( MyFile.list.last.directory? ).to be true }

    end

    context "commit changes" do

      it { expect( MyFile.changes.size ).to eq(1) }

      it { expect( MyFile.changes.first.type ).to eq("A") }

      it { expect( MyFile.changes.first.path ).to eq("testdir/.gitkeep") }

      it { expect( MyFile.commit('msg') ).to include('master')}

      it { expect( MyFile.changes.size ).to eq(0) }

    end

    context "add file to directory" do

      let(:file){ MyFile.create( filename: 'test2.txt', directory: 'testdir' ) }

      it { expect( file.path ).to eq('testdir/test2.txt') }

    end

    context "list directory content" do

      let(:dir) { MyFile.findOne("testdir") }

      it { expect( dir.content ).to be_a(Array) }

      it { expect( dir.content.first ).to be_a(MyFile) }

      it { expect( dir.content.first.filename ).to eq('test2.txt') }

    end

  end

end
