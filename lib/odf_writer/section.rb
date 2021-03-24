module ODFWriter

  ########################################################################################
  #
  # Section: poulate and grow sections
  #
  ########################################################################################
  class Section
    include Nested
    
    attr_accessor :collection
    
    ######################################################################################
    #
    # initialize
    #
    ######################################################################################
    def initialize(opts)
      @name       = opts[:name]
      @field      = opts[:field]
      @collection = opts[:collection]
      
      @fields     = []
      @bookmarks  = []
      @images     = []
      @texts      = []
      @tables     = []
      @sections   = []
    end #def
    
    ######################################################################################
    #
    # get_section_content
    #
    ######################################################################################
    def get_section_content( doc )
      return unless @section_node = find_section_node(doc)
      @section_node.content
    end #def
    
    ######################################################################################
    #
    # replace!
    #
    ######################################################################################
    def replace!(doc, manifest, file, row = nil)
    
      return unless @section_node = find_section_node(doc)
      
      @collection = get_collection_from_item(row, @field) if row
      
      @collection.each do |data_item|
      
        new_section = get_section_node
        #
        # experimental: new node must be added to doc prior to replace!
        #               else new_section does not have a name space
        #
        @section_node.before(new_section) 
        
        @tables.each    { |t| t.replace!(new_section, manifest, file, data_item) }
        
        @sections.each  { |s| s.replace!(new_section, manifest, file, data_item) }
        
        @texts.each     { |t| t.replace!(new_section, data_item) }
        
        @fields.each    { |f| f.replace!(new_section, data_item) }
        
        @bookmarks.each { |b| b.replace!(new_section, data_item) }
        
        @images.each    { |b| b.replace!(new_section, manifest, file, data_item) }
        
        #@section_node.before(new_section) #/experimental
        
      end
      
      Image.unique_image_names( doc) if @images.present?
      
      @section_node.remove
      
    end #def
    
    ######################################################################################
    #
    # private
    #
    ######################################################################################
    private
  
    def find_section_node(doc)
      sections = doc.xpath(".//text:section[@text:name='#{@name}']")
      sections.empty? ? nil : sections.first
    end #def
    
    def get_section_node
      node = @section_node.dup
      name = node.get_attribute('text:name').to_s
      @idx ||=0; @idx +=1
      node.set_attribute('text:name', "#{name}_#{@idx}")
      node
    end #def
    
  end #class
end #module
