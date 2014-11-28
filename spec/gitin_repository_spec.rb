require 'spec_helper'

describe Gitin::Repository do
  
  before(:all){ cleanup }

  context "#new" do
  
    context "option as string" do

      it { expect(Gitin::Repository.new(spec_git_path)).to be_a(Gitin::Repository) }

      it { expect(Gitin::Repository.new(spec_git_path).path).to eq(spec_git_path) }

    end

    context "options as hash" do

      context "@path" do

        it { expect(Gitin::Repository.new( path: spec_git_path)).to be_a(Gitin::Repository) }

        it { expect(Gitin::Repository.new(spec_git_path).path).to eq(spec_git_path) }
        
      end

      context "@username" do

        let!(:repo){ Gitin::Repository.new( path: spec_git_path, username: 'test' ) }

        it { expect( repo.username ).to eq('test') }

      end

      context "@email" do

        let!(:repo){ Gitin::Repository.new( path: spec_git_path, email: 'test@localhost' ) }

        it { expect( repo.email ).to eq('test@localhost') }

      end

    end

    context "creates a new git repository" do

      let!(:repo){ create_repo }

      it { expect( File ).to exist( File.join(repo.path,'.git')) }

    end

  end

  context "#clean?" do

    let!(:repo){ create_repo }

    it { expect( repo.clean? ).to be true }

  end

  context "#changes" do

    let!(:repo){ create_repo }

    context "returns the numberof changed files in the git repo" do

      it{ expect( repo.changes.size ).to eq(0) }

    end

  end

  context "#commit" do

    before(:all) do
      @repo = clean_create_repo
      @repo.create('test.txt', 'content')
    end

    it { expect( @repo.clean? ).to be false }

    it { expect( @repo.changes.size ).to eq(1) }

    it { expect( @repo.changes.first.path ).to eq('test.txt') }

    it { expect( @repo.commit('msg')).to be_a(String) }

    it { expect( @repo.clean? ).to be true }

  end

end
