module ODFWriter
  
  ########################################################################################
  #
  # TextReader: find all texts and set name
  #
  ########################################################################################
  class TextReader < FieldReader
    
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
    # paths
    #
    ######################################################################################
    def paths( file, doc)
      
      # find nodes with matching field elements matching [FIELD] pattern
      nodes = doc.xpath("//text()").select{|node| scan(node).present? }
      
      # find path for each field
      paths = nil
      nodes.each do |node|
        leaf  = {:texts => scan(node)}
        paths = PathFinder.trail(node, leaf, :root => file, :paths => paths)
      end #each
      paths.to_h
      
    end #def
    
    ######################################################################################
    # private
    ######################################################################################
    
    private
    
    def scan(node)
      if name 
        node.text.scan(/(?<=#{Regexp.escape Text::DELIMITERS[0]})#{name.upcase}(?=#{Regexp.escape Text::DELIMITERS[1]})/)
      else
        node.text.scan(/(?<=#{Regexp.escape Text::DELIMITERS[0]})[A-Z0-9_]+?(?=#{Regexp.escape Text::DELIMITERS[1]})/)
      end
    end #def
    
  end #class
end #module
