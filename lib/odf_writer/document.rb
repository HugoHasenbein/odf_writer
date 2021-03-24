module ODFWriter

  ########################################################################################
  #
  # Document: create document from template
  #
  ########################################################################################
  class Document
    include Images
    
    ######################################################################################
    #
    # initialize
    #
    ######################################################################################
    def initialize(name = nil, io: nil)
    
      @template = ODFWriter::Template.new(name, io: io)
      
      @fields = []
      @field_readers = []
      
      @texts = []
      @text_readers = []
      
      @bookmarks = []
      @bookmark_readers = []
      
      @images = []
      @image_readers = []
      
      @tables = []
      @table_readers = []
      
      @sections = []
      @section_readers = []
      
      @styles = []
      @list_styles = []
      
      if block_given?
        instance_eval(&block)
      end
      
    end #def
    
    ######################################################################################
    #
    # add_field
    #
    ######################################################################################
    def add_field(name, value, opts={})
      opts.merge!(:name => name, :value => value)
      field = Field.new(opts)
      @fields << field
    end #def
    
    ######################################################################################
    #
    # add_field_reader
    #
    ######################################################################################
    def add_field_reader(name=nil)
      @field_readers << FieldReader.new(:name => name)
    end #def
    
    ######################################################################################
    #
    # add_text
    #
    ######################################################################################
    def add_text(name, value, opts={})
      opts.merge!(:name => name, :value => value)
      text = Text.new(opts)
      @texts << text
    end #def
    
    ######################################################################################
    #
    # add_text_reader
    #
    ######################################################################################
    def add_text_reader(name=nil)
      @text_readers << TextReader.new(:name => name)
    end #def
    
    ######################################################################################
    #
    # add_bookmark
    #
    ######################################################################################
    def add_bookmark(bookmark_name, value, opts={})
      opts.merge!(:name => bookmark_name, :value => value)
      bm = Bookmark.new(opts)
      @bookmarks << bm
    end #def
    
    ######################################################################################
    #
    # add_bookmark_reader
    #
    ######################################################################################
    def add_bookmark_reader(name=nil)
      @bookmark_readers << BookmarkReader.new(:name => name)
    end #def
    
    ######################################################################################
    #
    # add_image
    #
    ######################################################################################
    def add_image(name, opts={})
      opts.merge!(:name => name)
      img = Image.new(opts)
      @images << img
    end #def
    
    ######################################################################################
    #
    # add_image_reader
    #
    ######################################################################################
    def add_image_reader(name=nil)
      @image_readers << ImageReader.new(:name => name)
    end #def
    
    ######################################################################################
    #
    # add_table
    #
    ######################################################################################
    def add_table(name, collection, opts={})
      opts.merge!(:name => name, :collection => collection)
      table = Table.new(opts)
      @tables << table
      yield(table)
    end #def
    
    ######################################################################################
    #
    # add_table_reader
    #
    ######################################################################################
    def add_table_reader(name=nil)
      @table_readers << TableReader.new(:name => name)
    end #def
    
    ######################################################################################
    #
    # add_section
    #
    ######################################################################################
    def add_section(name, collection, opts={})
      opts.merge!(:name => name, :collection => collection)
      section = Section.new(opts)
      @sections << section
      yield(section)
    end #def
    
    ######################################################################################
    #
    # add_section_reader
    #
    ######################################################################################
    def add_section_reader(name=nil)
      @section_readers << SectionReader.new(:name => name)
    end #def
    
    ######################################################################################
    #
    # add_style
    #
    ######################################################################################
    def add_style( *styles )
      @styles << Style.new( *styles )
    end #def
    
    ######################################################################################
    #
    # add_list_style
    #
    ######################################################################################
    def add_list_style( *list_styles )
      list_styles.each do |list_style|
        listdef = ListStyle.new( list_style )
        @list_styles << listdef
      end
    end #def
    
    ######################################################################################
    #
    # extract
    #
    ######################################################################################
    def tree
      results = {}
      @template.get_content do |name, doc|
        file = File.basename(name, File.extname(name)).parameterize.to_sym
        results.deep_merge!( leafs( doc, file ))
      end
      results
    end #def
    
    ######################################################################################
    #
    # leafs
    #
    ######################################################################################
    def leafs( doc, file )
      results={}
      results.deep_merge! @bookmark_readers.map { |r| r.get_paths(doc, file) }.inject{|m,n| m.deep_merge(n){|k, v1,v2| v1 + v2}}
      results.deep_merge! @field_readers.map    { |r| r.get_paths(doc, file) }.inject{|m,n| m.deep_merge(n){|k, v1,v2| v1 + v2}}
      results.deep_merge! @text_readers.map     { |r| r.get_paths(doc, file) }.inject{|m,n| m.deep_merge(n){|k, v1,v2| v1 + v2}}
      results.deep_merge! @image_readers.map    { |r| r.get_paths(doc, file) }.inject{|m,n| m.deep_merge(n){|k, v1,v2| v1 + v2}}
      results
    end #def
    
    ######################################################################################
    #
    # write
    #
    ######################################################################################
    def write(dest = nil)
    
      @template.update_content do |file|
      
        file.update_files do |doc, manifest|
        
          @styles.each      { |s| s.add_style(doc) }
          @list_styles.each { |s| s.add_list_style(doc)  }
          
          @sections.each    { |s| s.replace!(doc, manifest, file)  }
          @tables.each      { |t| t.replace!(doc, manifest, file)  }
          
          @texts.each       { |t| t.replace!(doc)  }
          @fields.each      { |f| f.replace!(doc)  }
          
          @bookmarks.each   { |b| b.replace!(doc)  }
          @images.each      { |i| i.replace!(doc, manifest, file) }
          
          Image.unique_image_names( doc ) if @images.present?
        end
        
      end
      
      if dest
        ::File.open(dest, "wb") {|f| f.write(@template.data) }
      else
        @template.data
      end
      
    end #def
    
  end #class
end #module
