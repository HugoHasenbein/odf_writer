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
    
    ######################################################################################
    #
    # replace!
    #
    ######################################################################################
    def replace!(content, item = nil)
    
      return unless node = find_text_node(content)
      
      text = value(item)
      
      @parser = Parser::Default.new(text, node, 
        :doc                 => content,
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
    
    ######################################################################################
    # find_text_node
    ######################################################################################
    def find_text_node(doc)
      texts = doc.xpath(".//text:p[text()='#{placeholder}']")
      if texts.empty?
        texts = doc.xpath(".//text:p/text:span[text()='#{placeholder}']")
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
    
    ######################################################################################
    # placeholder
    ######################################################################################
    def placeholder
      "#{DELIMITERS[0]}#{@name.to_s.upcase}#{DELIMITERS[1]}"
    end #def
  end #class
end #module
