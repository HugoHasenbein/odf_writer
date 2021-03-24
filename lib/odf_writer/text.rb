module ODFWriter

  ########################################################################################
  #
  # Text: replace text items
  #
  ########################################################################################
  class Text < Field
  
    ######################################################################################
    #
    # constants
    #
    ######################################################################################
    DELIMITERS = %w({ })
    
    attr_accessor :parser
    
    ######################################################################################
    #
    # initialize
    #
    ######################################################################################
    # inherited
    
    ######################################################################################
    #
    # replace!
    #
    ######################################################################################
    def replace!(doc, data_item = nil)
    
      return unless node = find_text_node(doc)
      
      text_value = get_value(data_item)
      
      @parser = Parser::Default.new(text_value, node, 
        :doc                 => doc,
        :remove_classes      => @remove_classes,
        :remove_class_prefix => @remove_class_prefix,
        :remove_class_suffix => @remove_class_suffix
      )
      
      @parser.paragraphs.each do |p|
        node.before(p)
      end
      
      node.remove
      
    end #def
    
    ######################################################################################
    #
    # private
    #
    ######################################################################################
    private
    
    def to_placeholder
      if DELIMITERS.is_a?(Array)
        "#{DELIMITERS[0]}#{@name.to_s.upcase}#{DELIMITERS[1]}"
      else
        "#{DELIMITERS}#{@name.to_s.upcase}#{DELIMITERS}"
      end
    end #def
    
    def find_text_node(doc)
      texts = doc.xpath(".//text:p[text()='#{to_placeholder}']")
      if texts.empty?
        texts = doc.xpath(".//text:p/text:span[text()='#{to_placeholder}']")
        if texts.empty?
          texts = nil
        else
          texts = texts.first.parent
        end
      else
        texts = texts.first
      end
      
      texts
    end #def
    
  end #class
end #module
