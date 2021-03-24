module ODFWriter
  
  ########################################################################################
  #
  # PathFinder: find all fields and set name
  #
  ########################################################################################
  class PathFinder
  
    class << self
      ######################################################################################
      #
      # trail: find path in odt document, whereby only sections and tabes are searched as ancestors
      #
      #        node: Nokogiri node
      #        leaf: hash, f.i. {:fields => ["NAME", "STREET", "ZIP", "PLACE"]}
      #        
      #        options:
      #                  :root   => :content | :styles, defaults to :root
      #                  :paths  => :auto vivifying-hash, defaults to it
      #
      ######################################################################################
      def trail( node, leaf, options={})
        
        # determine root
        root  = options[:root]  || :root
        
        # create auto-vivifying hash
        paths = options[:paths] || Hash.new { |h, k| h[k] = Hash.new(&h.default_proc)  }
        
        # for tables and sections add level with node name
        ancestors = node.ancestors.reverse.select{|ancestor| %w(section table).include?(ancestor.name)}
        
        path = [:files, root] + ancestors.map do |ancestor|
          case ancestor.name
          when "section"
            [:sections, ancestor.attr("text:name")]
          when "table"
            [:tables,   ancestor.attr("table:name")]
          else
            []
          end
        end.flatten #map
        
        # add each field in a nested hash
        paths.dig(*path)[leaf.keys.first]  = paths.dig(*path)[leaf.keys.first].presence || [] # cannot do '||=''
        paths.dig(*path)[leaf.keys.first] += leaf.values.first
        
        paths
       end #def
     
     end #self
   end #class
end #module
