module ODFWriter
  
  ########################################################################################
  #
  # TextReader: find all texts and set name
  #
  ########################################################################################
  class TextReader
    
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
    # get_texts
    #
    ######################################################################################
    def get_texts( doc )
      #
      # get all text elements matching {TEXT} pattern
      #
      #doc.xpath(".//office:text"         ).text.scan(/(?<=\{)[A-Z0-9_]+?(?=\})/) + 
      #doc.xpath(".//office:master-styles").text.scan(/(?<=\{)[A-Z0-9_]+?(?=\})/)
      doc.xpath("./*").text.scan(/(?<=\{)[A-Z0-9_]+?(?=\})/)
    end #def
    
    ######################################################################################
    #
    # get_paths: limit to paths with ancestors 'text '(content.xml) and master-styles (styles.xml)
    #
    ######################################################################################
    def get_paths( doc, root=:root)
      
      # find nodes with matching field elements matching [FIELD] pattern
      nodes = doc.xpath("//text()").select{|node| scan(node).present? }
      
      # find path for each field
      paths = nil
      nodes.each do |node|
        leaf  = {:texts => scan(node)}
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
        node.text.scan(/(?<=\{)#{name.upcase}(?=\})/)
      else
        node.text.scan(/(?<=\{)[A-Z0-9_]+?(?=\})/)
      end
    end #def
    
  end #class
end #module
