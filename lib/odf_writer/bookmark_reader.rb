module ODFWriter
  
  ########################################################################################
  #
  # BookmarkReader: find all bookmarks and set name
  #
  ########################################################################################
  class BookmarkReader
    
    attr_accessor :name
    
    ######################################################################################
    #
    # initialize
    #
    ######################################################################################
    def initialize(opts={})
      @name = opts[:name]
    end #def
    
    ######################################################################################
    #
    # get_bookmarks
    #
    ######################################################################################
    def get_bookmarks( doc )
     #doc.xpath(".//*[self::text:bookmark or self::text:bookmark-start]").map{|node| node.attr("text:name")}
     doc.xpath("./*[self::text:bookmark or self::text:bookmark-start]").map{|node| node.attr("text:name")}
    end #def
    
    ######################################################################################
    #
    # get_paths: limit to paths with ancestors 'text '(content.xml) and master-styles (styles.xml)
    #
    ######################################################################################
    def get_paths( doc, root=:root)
      
      # find nodes with matching field elements matching [BOOKMARK] pattern
      nodes = doc.xpath("//*[self::text:bookmark or self::text:bookmark-start]").select{|node| scan(node).present? }
      
      # find path for each field
      paths = nil
      nodes.each do |node|
        leaf  = {:bookmarks => scan(node)}
        paths = PathFinder.trail(node, leaf, :root => root, :paths => paths)
      end #each
      paths.to_h
      
    end #def
    
    ######################################################################################
    # private
    ######################################################################################
    
    private
    
    def scan(node)
      if name 
        node.attr("text:name") == name.upcase ? [node.attr("text:name")] : []
      else
        node.attr("text:name")
      end
    end #def
    
  end #class
end #module
