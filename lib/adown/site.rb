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
            @name = ''
            @images = []
        end

        def download(directory)
            fetch if @url.nil?

            directory = File.join(directory, @id.to_s)

            Dir.mkdir(directory) unless Dir.exists?(directory)
            
            threads = []
            @images.each do |image|
                threads << Thread.new {
                    image.download(directory)
                }
            end
            threads.each {|t| t.join}
        end
    end
    
    class Image < Request
        
        def download(directory)
            puts "Downloading Image"
            fetch if @url.nil?
            
            file_path = File.expand_path("#{@id}.jpg", directory)

            File.open(file_path,'w') do |file|
                file << HTTParty.get(@url)
            end
        end
    end
end
