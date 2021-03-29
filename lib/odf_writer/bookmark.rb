module ODFWriter

  ########################################################################################
  #
  # Bookmark: replace bookmarks with given name
  #
  ########################################################################################
  class Bookmark < Field
    
    ######################################################################################
    #
    # replace!
    #
    ######################################################################################
    def replace!(doc, item = nil)
    
      nodes = find_bookmark_nodes(doc)
      return if nodes.blank?
      
      text = value(item)
      text = text.encode(universal_newline: true)
      
      text_node_array = text.split(/\n/).map{|a| Nokogiri::XML::Text.new(a, doc) }
      unless text_node_array.length == 1
        text_node_array = text_node_array.inject([]) do |collector, node| 
          collector << Nokogiri::XML::Node.new("line-break", doc) unless collector.empty?
          collector << node
        end 
      end
      
      nodes.each do |node|
      
        case node.name
        
        when "bookmark"
          text_node_array.each {|tn| node.before(tn)}
          
          #
          # find bookmark
          #
          bm  =  "text:bookmark[@text:name='#{@name}']"
          bmn = doc.xpath(".//.//*[self::#{bm}]")
          #
          # delete bookmark
          #
          bmn.each  {|b| b.remove }
          
        when "bookmark-start"
          text_node_array.each {|tn| node.before(tn)}
          
          #
          # find bookmark-start 
          #
          bms  =  "text:bookmark-start[@text:name='#{@name}']"
          bmsn = doc.xpath(".//.//*[self::#{bms}]")
          #
          # find bookmark text 
          #
          bme  = "text:bookmark-end[@text:name='#{@name}']"
          bmen = doc.xpath(".//.//*[self::#{bme}]")
          #
          # find bookmark-end 
          #
          bmn  = doc.xpath(".//text()[preceding-sibling::#{bms} and following-sibling::#{bme}]")
          #
          # delete bookmark -start, text and -end
          #
          bmn.each  {|b| b.remove }
          bmsn.each {|b| b.remove }
          bmen.each {|b| b.remove }
          
        end #case
      end #each
      
    end #def
    
    ######################################################################################
    #
    # private
    #
    ######################################################################################
    private
    
    def find_bookmark_nodes(doc)
      doc.xpath(".//*[self::text:bookmark[@text:name='#{@name}'] or self::text:bookmark-start[@text:name='#{@name}']]")
    end #def
    
  end #class
end #module
