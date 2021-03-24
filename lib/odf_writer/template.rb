module ODFWriter

  ########################################################################################
  #
  # Template: handles files in .odt-package
  #
  ########################################################################################
  class Template
    
    ######################################################################################
    #
    # constant - we only work and content and styles (contains headers and footers) parts of odf
    #
    ######################################################################################
    CONTENT_FILES = ['content.xml', 'styles.xml']
    MANIFEST      = 'META-INF/manifest.xml'
    MANIFEST_FILE = 'manifest.xml'
    
    attr_accessor :output_stream
    
    ######################################################################################
    #
    # initialize
    #
    ######################################################################################
    def initialize(template = nil, io: nil)
      raise "You must provide either a filename or an io: string" unless template || io
      raise "Template [#{template}] not found." unless template.nil? || ::File.exist?(template)
      
      @template = template
      @io = io
    end #def
    
    ######################################################################################
    #
    # get_content
    #
    ######################################################################################
    def get_content(&block)
    
      #
      # open zip file and loop through files in zip file
      #
      get_template_entries.each do |entry|
      
        next if entry.directory?
        
        entry.get_input_stream do |is|
        
          data = is.sysread
          
          if CONTENT_FILES.include?(entry.name)
            yield entry.name, get_content_from_data(data)
          end
          
        end
      end
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
      
      manifest = nil
      
      #
      # search manifest.xml
      #
      get_template_entries.each do |entry|
      
        next if entry.directory?
        
        entry.get_input_stream do |is|
          if MANIFEST == entry.name
            manifest = is.sysread.dup
          end
        end
      end
      
      #
      # search conten.xml and styles.xml
      #
      get_template_entries.each do |entry|
      
        next if entry.directory?
        
        entry.get_input_stream do |is|
          data = is.sysread
            if CONTENT_FILES.include?(entry.name)
              process_entry(data, manifest, &block)
            end
            unless entry.name == MANIFEST
              @output_stream.put_next_entry(entry.name)
              @output_stream.write data
            end
        end
      end
      
      if manifest
        @output_stream.put_next_entry(MANIFEST)
        @output_stream.write manifest
      end
      
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
    
    #
    # get_template_entries: just open zip file or buffer
    # 
    def get_template_entries
    
      if @template
        Zip::File.open(@template)
      else
        Zip::File.open_buffer(@io.force_encoding("ASCII-8BIT"))
      end
    end #def
    
    #
    # get_content_from_entry: read data from file
    # 
    def get_content_from_data(raw_xml)
      Nokogiri::XML(raw_xml)
    end #def
    
    #
    # process_entry: provide Nokogiri Object to caller, after having provided a file
    # 
    def process_entry(entry, manifest)
      doc = Nokogiri::XML(entry   ) # { |x| x.noblanks }
      man = Nokogiri::XML(manifest) # { |x| x.noblanks }
      yield doc, man
     #entry.replace(doc.to_xml(save_with: Nokogiri::XML::Node::SaveOptions::AS_XML))
      # remove spurious whitespaces between tags ">  <" becomes "><"
      entry.replace(doc.to_xml(save_with: Nokogiri::XML::Node::SaveOptions::AS_XML).squish.gsub(/(?<=>)\s+(?=<)/, ""))
     # Microsoft Words complains if no trailing newline is present
      # (save_with: Nokogiri::XML::Node::SaveOptions::AS_XML)
      manifest.replace(man.to_xml(save_with: Nokogiri::XML::Node::SaveOptions::AS_XML))
    end #def
    
  end #class
end #module
