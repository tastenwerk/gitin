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

  end

end
