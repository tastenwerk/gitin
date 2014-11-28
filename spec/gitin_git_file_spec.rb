require 'spec_helper'

describe Gitin::GitFile do

  let(:repo){ clean_create_repo }

  context "#build" do
  
    let(:file){ repo.build("test.txt") }

    it { expect(file).to be_a(Gitin::GitFile) }

    it { expect(repo.clean?).to be true }

  end

  context "@path" do

    context "returns the relative path within repo (on root)" do

      let(:file){ repo.build("test.txt") }

      it{ expect(file.path).to eq("test.txt") }

    end

    context "returns the nested path relative to repo" do

      let(:file){ repo.build("t/test.txt") }

      it{ expect(file.path).to eq("t/test.txt") }

    end

  end

  context "#create" do

    context "file on root" do

      let(:file){ repo.create("test.txt") }

      it { expect(File).to exist(file.absolute_path) }

    end

    context "nested file" do

      let(:file) { repo.create("test/test2.txt") }

      it { expect(File).to exist(file.absolute_path ) }

    end

    context "file with content" do

      let(:file) { repo.create("test/test2.txt", "test content") }

      it { expect(File).to exist(file.absolute_path ) }

      it { expect(file.content).to eq("test content") }

    end

  end

  context "find one file" do
    
    before(:all) do
      @repo = clean_create_repo
      @repo.create("test.txt", "content")
    end

    let(:file){ @repo.findOne("test.txt") }

    it { expect(file).to be_a(Gitin::GitFile) }

    it { expect( File ).to exist(file.absolute_path) }

    it { expect(file.content).to eq("content") }

  end

  context "change file's content" do

    # let(:repo){ clean_create_repo }
    #
    # let(:file){ repo.create("test.txt", "test content") }
    #
  end

end

