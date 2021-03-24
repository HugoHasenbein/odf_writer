module ODFWriter

  ########################################################################################
  #
  # Nested: provide data to nestable items
  #
  ########################################################################################
  module Nested
  
    def add_field(name, data_field=nil, &block)
      opts = {:name => name, :data_field => data_field}
      field = Field.new(opts, &block)
      @fields << field
    end #def
    alias_method :add_column, :add_field
    
    def add_bookmark(bookmark_name, data_field=nil, &block)
      opts = {:name => bookmark_name, :data_field => data_field}
      bm = Bookmark.new(opts, &block)
      @bookmarks << bm
    end #def
    
    def add_image(image_name, &block)
      opts = {:name => image_name }
      image = Image.new(opts, &block)
      @images << image
    end #def
    
    def add_text(name, data_field=nil, &block)
      opts = {:name => name, :data_field => data_field}
      text = Text.new(opts, &block)
      @texts << text
    end #def
    
    def add_table(table_name, collection_field, opts={})
      opts.merge!(:name => table_name, :collection_field => collection_field)
      tab = Table.new(opts)
      @tables << tab
      yield(tab)
    end #def
    
    def add_section(section_name, collection_field, opts={})
      opts.merge!(:name => section_name, :collection_field => collection_field)
      sec = Section.new(opts)
      @sections << sec
      yield(sec)
    end #def
    
    
    def get_collection_from_item(item, collection_field)
    
      return item[collection_field] if item.is_a?(Hash)
      
      if collection_field.is_a?(Array)
        tmp = item.dup
        collection_field.each do |f|
          if f.is_a?(Hash)
            tmp = tmp.send(f.keys[0], f.values[0])
          else
            tmp = tmp.send(f)
          end
        end
        collection = tmp
      elsif collection_field.is_a?(Hash)
        collection = item.send(collection_field.keys[0], collection_field.values[0])
      else
        collection = item.send(collection_field.to_sym)
      end
      
      return collection
    end #def
    
  end #module
end #module
