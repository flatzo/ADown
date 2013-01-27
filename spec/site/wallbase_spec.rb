require_relative '../spec_helper'

require 'adown'

describe Wallbase::Album do
  
  before :each do
    @album = Wallbase::Album.new 81218
  end
  
  describe "#new" do
    it "initialize with an id" do
      lambda { Wallbase::Album.new 81218 }.should_not raise_exception ArgumentError
    end
  end
  
  describe "#download" do 
    it "downloads pictures (3..5) from an album" do
      images = @album.download('/tmp/ADown/spec/wallbase/', {:range => (3..5)})
      images.each do |img|
        ((Time.now - File.stat(img.file_path).mtime).to_i.should eql 0)
      end
    end
  end
  
  describe "#fetch" do
    it "initialize images with path to fetch them from" do
      images = @album.fetch
      images.each do |img|
        img.url_path.should_not be_nil
      end
    end
    
    it "do not fetch images informations" do
      images = @album.fetch
      images.each do |img|
        img.url.should be_nil
      end
    end
  end
  
end