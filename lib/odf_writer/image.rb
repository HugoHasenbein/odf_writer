module ODFWriter

  ########################################################################################
  #
  # Image: replace images
  #
  ########################################################################################
  class Image
  
    ######################################################################################
    #
    # constants
    #
    ######################################################################################
    IMAGE_DIR_NAME = "Pictures"
    
    ######################################################################################
    #
    # attribute accessors
    #
    ######################################################################################
    attr_accessor :name, :data_field, :data
                  
    ######################################################################################
    #
    # initialize
    #
    ######################################################################################
    def initialize(opts, &block)
    
      @name       = opts[:name]      # name in template
      @data_field = opts[:data_field]
      @data       = opts[:data]      # image in memory as hash: filename, width, height, bytes
      
      unless @data
        if block_given?
          @block = block
        else
          #
          #TODO: self.get_image_data(item) does not yet exist
          #
          #@block = lambda { |item| self.get_image_data(item) }
          @block = lambda { |item|  }
        end
      end
      
    end #def
    
    ######################################################################################
    #
    # replace!
    #
    ######################################################################################
    def replace!(doc, manifest, file, data_item=nil )
    
      value = get_values(data_item)
      
      if value
      
        nodes = find_image_nodes( doc )
        return if nodes.blank?
        
        man = manifest.xpath("//manifest:manifest") rescue nil
        
        nodes.each do |node|
        
          # we have data in memory with filename
          path = ::File.join(IMAGE_DIR_NAME, "#{SecureRandom.hex(20).upcase}#{::File.extname(value[:filename])}")
          mime = Rack::Mime.mime_type(File.extname(value[:filename]))
          
          node.attribute('href').value = path
          
          if node.attribute('mime-type').present?
            node.attribute('mime-type').value = mime
          else
            node.set_attribute('mime-type', mime)
          end
          
          if value[:width] && value[:height]
            parent = node.parent
            if parent.name == "frame"
              width  = parent.attribute('width').value
              height = parent.attribute('height').value
              parent.attribute('height').value = recalc_height(:origx => value[:width], :origy => value[:height], :newx => width, :newy => height)
            end
          end
          
          if man.present?
            file_entry = Nokogiri::XML::Node.new('manifest:file-entry', doc)
            file_entry.set_attribute('manifest:full-path', path)
            file_entry.set_attribute('manifest:media-type', mime)
            man.children.after file_entry
          end
          
          file.output_stream.put_next_entry(path)
          file.output_stream.write value[:bytes]
          
        end
      end
      
    end #def
    
    def self.unique_image_names(doc)
      nodes   = doc.xpath("//draw:frame[@draw:name='#{@name}']")
      padding = Math.log10(nodes.length).to_i + 1 if nodes.present?
      nodes.each_with_index do |node, i|
        num = "%.#{padding}i" % i
        node.attribute('name').value = "IMAGE_#{num}_" + node.attribute('name').value
      end
    end #def
    
    
    def get_values(item = nil)
      @data.presence || @block.call(item) 
    end
    
    def extract_value(item)
      return unless data_item
      
      key = @data_field || @name
      
      if data_item.respond_to?(key.to_s.downcase.to_sym)
        data_item.send(key.to_s.downcase.to_sym)
      else
        raise "Can't find field [#{key}] in this #{data_item.class}"
      end
      
    end #def
    
    ######################################################################################
    #
    # private
    #
    ######################################################################################
    private
    
    def find_image_nodes(doc)
      doc.xpath(".//draw:frame[@draw:name='#{@name}']/draw:image")
    end #def
    
    
    def recalc_height(nums)
    
      numericals = {}
      dimensions = {}
      
      [:origx, :origy, :newx, :newy].each do |v|
        num = nums[v].to_s.match(/[0-9.]+/)
        numericals[v] = num[0].to_f if num
        dimensions[v] = nums[v].gsub(/\A[0-9.]+/, "")
      end
      
      if [:origx, :origy, :newx, :newy].all?{|i| numericals[i].present? }
        y = numericals[:newx] / numericals[:origx] * numericals[:origy]
      end 
      
      y ? "#{'%.3f'%y}#{dimensions[:newy]}" : nums[:newy]
      
    end #def
    
  end #class
end #module
