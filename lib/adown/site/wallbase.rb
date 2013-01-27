require 'httparty'
require 'nokogiri'
require 'v8'

module Wallbase
    class Album < ADown::Album
        attr :images
        base_uri 'http://wallbase.cc'
        format :json
        headers 'X-Requested-With' => 'XMLHttpRequest'
        headers 'Content-Length' => '0'

        def initialize(id)
            super(id)
            @path =  "/user/collection/#{id}/0/0"
        end

        def fetch
            response = self.class.post(@path)

            response.each do |image_info|
                @images << Image.new(image_info)
            end
            @images
        end

        def next_page
            @page += 1
            @path = "/user/collection/#{id}/0/#{32*@page}"
        end
    end

    class Image < ADown::Image
        base_uri 'http://wallbase.cc'
        format :html

        def initialize(image_info)
            @id = image_info['wall_id']
            @path = "/wallpaper/#{@id}"
        end

        def fetch
            js = <<-eos
function B(a){var b="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";var c,d,e,f,g,h,i,j,k=0,l=0,m="",n=[];if(!a){return a}a+="";do{f=b.indexOf(a.charAt(k++));g=b.indexOf(a.charAt(k++));h=b.indexOf(a.charAt(k++));i=b.indexOf(a.charAt(k++));j=f<<18|g<<12|h<<6|i;c=j>>16&255;d=j>>8&255;e=j&255;if(h==64){n[l++]=String.fromCharCode(c)}else if(i==64){n[l++]=String.fromCharCode(c,d)}else{n[l++]=String.fromCharCode(c,d,e)}}while(k<a.length);m=n.join("");return m}
eos
            response = self.class.get(@path)
            script = response.xpath("//div[@id='bigwall']/script").to_s
            encoded_url = script.scan(/src=\"\'\+B\(\'(.*)\'/)[0]
            
            url = ''                          
            V8::Context.new do |ctx|
                ctx.eval(js)
                url = ctx.eval("B(#{encoded_url})")
            end

            @url = url.scan(/(.*\.jpg)/)[0][0].to_s
        end
    end
end
