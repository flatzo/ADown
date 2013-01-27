require 'httparty'
require 'nokogiri'

module ADown
  class Request
    include HTTParty
    class Parser::Request < HTTParty::Parser
      SupportedFormats.merge!({
        "text/html" => :html
      })

      protected

      def html
        Nokogiri::HTML(body)
      end

    end

    parser Parser::Request
  end

  class Album < Request
    def initialize(id)
      @id = id
      @page = 0
      @images = []
    end

    def download(directory, options = {})
      raise ArgumentError if options.has_key? :range and !options[:range].is_a? Range
      raise ArgumentError if options.has_key? :page and !options[:page].is_a? Integer
        
      @range = options[:range] if options.has_key? :range
      
      fetch if @url.nil?
      
      directory = File.join(directory, @id.to_s)
      directory = File.absolute_path directory
      
      ensure_dir_exists directory

      threads = []
      @images.each do |image|
        threads << Thread.new {
          image.download(directory)
        }
      end
      threads.each {|t| t.join}
        
      return @images
    end
    
    def ensure_dir_exists(directory)
      if(Dir.exists?(directory))
        return
      end
      d = ''
      directory.split(File::SEPARATOR).each do |dir|
        d = File.join(d,dir)
        Dir.mkdir(d) unless Dir.exists?(d)
      end
      Dir.mkdir(directory) unless Dir.exists?(directory)
    end
  end

  class Image < Request
    attr_reader :file_path, :url, :url_path 
    
    def download(directory)
      fetch if @url.nil?

      @file_path = File.expand_path("#{@id}.jpg", directory)

      File.open(@file_path,'w') do |file|
        file << HTTParty.get(@url)
      end
    end
  end
end
