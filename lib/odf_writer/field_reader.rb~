module ODFWriter
  
  ########################################################################################
  #
  # FieldReader: find all fields and set name
  #
  ########################################################################################
  class FieldReader
    
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
        leaf  = {:fields => scan(node)}
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
        node.text.scan(/(?<=#{Regexp.escape Field::DELIMITERS[0]})#{name.upcase}(?=#{Regexp.escape Field::DELIMITERS[1]})/)
      else
        node.text.scan(/(?<=#{Regexp.escape Field::DELIMITERS[0]})[A-Z0-9_]+?(?=#{Regexp.escape Field::DELIMITERS[1]})/)
      end
    end #def
    
   end #class
end #module
