# encoding: utf-8
#
# Ruby Gem to create a self populating Open Document Format (.odf) text file.
#
# Copyright © 2021 Stephan Wenzel <stephan.wenzel@drwpatent.de>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#

module ODFWriter

  ########################################################################################
  #
  # Template: handles files in .odt-package
  #
  ########################################################################################
  class Template
    
    ######################################################################################
    #
    # constants - we only work and content and styles (contains headers and footers) parts of odf
    #
    ######################################################################################
    CONTENT_ENTRIES = {
      "content.xml"  => {:symbol => :content,  :path => "content.xml"},
      "styles.xml"   => {:symbol => :styles,   :path => "styles.xml" }
    }.freeze
    
    CONTENT_FILES = {
      :content       => {:file => "content.xml",  :path => "content.xml"},
      :styles        => {:file => "styles.xml",   :path => "styles.xml" }
    }.freeze
    
    MANIFEST       = 'META-INF/manifest.xml'.freeze
    
    ######################################################################################
    #
    # accessors
    #
    ######################################################################################
    attr_accessor :output_stream
    
    ######################################################################################
    #
    # initialize
    #
    ######################################################################################
    def initialize(path = nil, zip_stream: nil)
    
      raise "You must provide either a filename or a zip_stream: string" unless path || zip_stream
      raise "Template [#{template}] not found." if path && !::File.exist?(path)
      
      @path       = path
      @zip_stream = zip_stream
    end #def
    
    ######################################################################################
    #
    # content
    #
    ######################################################################################
    def content(&block)
    
      entries.each do |entry|
      
        if entry.directory?
          next
          
        elsif CONTENT_ENTRIES.keys.include?(entry.name)
          # relevant file with valid file name
          entry.get_input_stream do |input_stream|
            file_content = input_stream.sysread
            yield CONTENT_ENTRIES[entry.name][:symbol], to_xml(file_content)
          end
          
        end #if
      end #each
    end #def
    
    ######################################################################################
    #
    # update_content: create write buffer for zip 
    #
    ######################################################################################
    def update_content
      @buffer = Zip::OutputStream.write_buffer do |out|
        @output_stream = out
        yield self
      end
    end
    
    ######################################################################################
    #
    # update_files: open and traverse zip directory, pick content.xml 
    #               and styles.xml process and eventually write contents 
    #               to buffer
    #               a pointer to manifest.xml is provided
    #
    ######################################################################################
    def update_files(&block)
      
      # get manifest, in case a file is added
      @manifest = manifest; digest = Digest::MD5.hexdigest(@manifest)
      
      entries.each do |entry|
      
        # search content files
        if entry.directory?
          next
          
        # process content files
        elsif CONTENT_ENTRIES.keys.include?(entry.name)
        
          entry.get_input_stream do |input_stream|
            file_content = input_stream.sysread
            file_symbol  = CONTENT_ENTRIES[entry.name][:symbol]
            process_entry(file_symbol, file_content, @manifest, &block)
            @output_stream.put_next_entry(entry.name)
            @output_stream.write file_content
          end #do
          
        else
          entry.get_input_stream do |input_stream|
            @output_stream.put_next_entry(entry.name)
            @output_stream.write input_stream.sysread
          end
        end #if
      end #each
      
      # eventually write back content file
      if @manifest && digest != Digest::MD5.hexdigest(@manifest)
        @output_stream.put_next_entry(MANIFEST)
        @output_stream.write @manifest
      end #if
      
    end #def
    
    
    ######################################################################################
    #
    # data: just a handle to data in buffer
    # 
    ######################################################################################
    def data
      @buffer.string
    end
    
    ######################################################################################
    #
    # private
    # 
    ######################################################################################
    private
    
    ######################################################################################
    # entries: just open zip file or buffer
    ######################################################################################
    def entries
      if @path
        Zip::File.open(@path)
      elsif @zip_stream
        Zip::File.open_buffer(@zip_stream.force_encoding("ASCII-8BIT"))
      end
    end #def
    
    ######################################################################################
    # manifest: read manifest 
    ######################################################################################
    def manifest
      manifest = nil
      entries.each do |entry|
        next if entry.directory?
        entry.get_input_stream do |input_stream|
          if MANIFEST == entry.name
            manifest = input_stream.sysread.dup
          end
        end
      end
      manifest
    end #def
    
    ######################################################################################
    # to_xml
    ######################################################################################
    def to_xml(raw_xml)
      Nokogiri::XML(raw_xml)
    end #def
    
    ######################################################################################
    # process_entry: provide Nokogiri Object to caller, after having provided a file
    ######################################################################################
    def process_entry(file_symbol, file_content, manifest)
    
      # create xml from file content
      doc = to_xml(file_content ) # { |x| x.noblanks }
      man = to_xml(manifest     ) # { |x| x.noblanks }
      
      # yield xml
      yield file_symbol, doc, man
      
      # replace file_content and manifest in place
      # remove spurious whitespaces between tags ">  <" becomes "><"
      file_content.replace(doc.to_xml(save_with: Nokogiri::XML::Node::SaveOptions::AS_XML).squish.gsub(/(?<=>)\s+(?=<)/, ""))
      # Microsoft Words complains if no trailing newline is present
      manifest.replace(man.to_xml(save_with: Nokogiri::XML::Node::SaveOptions::AS_XML))
      
    end #def
    
  end #class
end #module
