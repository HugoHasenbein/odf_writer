module ODFWriter
  
  ########################################################################################
  #
  # ImageReader: find all images and set name
  #
  ########################################################################################
  class ImageReader
    
    attr_accessor :name
    
    ######################################################################################
    #
    # initialize
    #
    ######################################################################################
    def initialize(opts)
      @name = opts[:name]
    end #def
    
    ######################################################################################
    #
    # get_image_names
    #
    ######################################################################################
    def get_image_names(doc)
      doc.xpath("//draw:frame[draw:image]").map{|node| node.attr("draw:name")}
     #doc.xpath("./draw:frame[draw:image]").map{|node| node.attr("draw:name")}
    end #def
    
    ######################################################################################
    #
    # get_paths: limit to paths with ancestors 'text '(content.xml) and master-styles (styles.xml)
    #
    ######################################################################################
    def get_paths( doc, root=:root)
      
      # find nodes with matching field elements matching [BOOKMARK] pattern
      nodes = doc.xpath("//draw:frame[draw:image]").select{|node| scan(node).present? }
      
      # find path for each field
      paths = nil
      nodes.each do |node|
        leaf  = {:images => scan(node)}
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
        node.attr("draw:name") == name.upcase ? [node.attr("draw:name")] : []
      else
        node.attr("draw:name")
      end
    end #def
  end #class
end #module
