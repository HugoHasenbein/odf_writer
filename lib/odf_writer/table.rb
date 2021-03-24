module ODFWriter

  ########################################################################################
  #
  # Table: poulate and grow tables
  #
  ########################################################################################
  class Table
  
    include Nested
    
    attr_accessor :collection
    
    ######################################################################################
    #
    # initialize
    #
    ######################################################################################
    def initialize(opts)
      @name          = opts[:name]
      @field         = opts[:field]
      @collection    = opts[:collection]
         
      @fields        = []
      @texts         = []
      @tables        = []
      @images        = []
      @bookmarks     = []
      
      @template_rows = []
      @header        = opts[:header] || false
      @skip_if_empty = opts[:skip_if_empty] || false
      
    end #def
    
    ######################################################################################
    #
    # replace!
    #
    ######################################################################################
    def replace!(doc, manifest, file, row = nil)
    
      return unless table = find_table_node(doc)
      
      @template_rows = table.xpath("table:table-row")
      
      @header = table.xpath("table:table-header-rows").empty? ? @header : false
      
      @collection = get_collection_from_item(row, @field) if row
      
      if @skip_if_empty && @collection.empty?
        table.remove
        return
      end
      
      @collection.each do |data_item|
      
        new_node = get_next_row
        #
        # experimental: new node must be added to doc prior to replace!
        #               else new_section does not have a name space
        #
        table.add_child(new_node)
        
        @tables.each    { |t| t.replace!(new_node, manifest, file, data_item) }
        
        @texts.each     { |t| t.replace!(new_node, data_item) }
        
        @fields.each    { |f| f.replace!(new_node, data_item) }
        
        @images.each    { |f| f.replace!(new_node, manifest, file, data_item) }
        
        #table.add_child(new_node)
        
      end
      Image.unique_image_names( doc) if @images.present?
      
      @template_rows.each_with_index do |r, i|
        r.remove if (get_start_node..template_length) === i
      end
      
    end #def
    
    ######################################################################################
    #
    # private
    #
    ######################################################################################
    private
  
    def get_next_row
      @row_cursor = get_start_node unless defined?(@row_cursor)
      
      ret = @template_rows[@row_cursor]
      if @template_rows.size == @row_cursor + 1
        @row_cursor = get_start_node
      else
        @row_cursor += 1
      end
      return ret.dup
    end #def
    
    def get_start_node
      @header ? 1 : 0
    end #def
    
    def template_length
      @tl ||= @template_rows.size
    end #def
    
    def find_table_node(doc)
      tables = doc.xpath(".//table:table[@table:name='#{@name}']")
      tables.empty? ? nil : tables.first
    end #def
    
  end #class
end #module
