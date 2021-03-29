module ODFWriter

  ########################################################################################
  #
  # Field: replace fields
  #
  ########################################################################################
  class Field
  
    ######################################################################################
    #
    # constants
    #
    ######################################################################################
    DELIMITERS = %w([ ])
    
    ######################################################################################
    #
    # constants
    #
    ######################################################################################
    attr_accessor :name
    
    ######################################################################################
    #
    # initialize
    #
    ######################################################################################
    def initialize(options, &block)
    
      @name                = options[:name]
      @value               = options[:value]
      @field               = options[:field]
      @key                 = @field || @name
      @proc                = options[:proc]
      
      @remove_classes      = options[:remove_classes]
      @remove_class_prefix = options[:remove_class_prefix]
      @remove_class_suffix = options[:remove_class_suffix]
      
      @value ||= @proc
      
      unless @value
        if block_given?
          @value = block
        else
          @value = lambda { |item, key| field(item, key) }
        end
      end
    end #def
    
    ######################################################################################
    #
    # replace!
    #
    ######################################################################################
    def replace!(content, item = nil)
      txt = content.inner_html
      txt.gsub!(placeholder, sanitize(value(item)))
      content.inner_html = txt
    end #def
    
    ######################################################################################
    #
    # value
    #
    ######################################################################################
    def value(item = nil)
      @value.is_a?(Proc) ? @value.call(item, @key) : @value
    end #def
    
    ######################################################################################
    #
    # field
    #
    ######################################################################################
    def field(item, key)
      case item
      when NilClass
        key
      when Hash
        hash_value(item, key)
      else
        item_field(item, key)
      end
    end #def
    
    ######################################################################################
    #
    # private
    #
    ######################################################################################
    private
    
    ######################################################################################
    # hash_value
    ######################################################################################
    def hash_value(hash, key)
      hash[key.to_s]            || hash[key.to_sym] || 
      hash[key.to_s.underscore] || hash[key.to_s.underscore.to_sym]
    end #def
    
    ######################################################################################
    # item_field
    ######################################################################################
    def item_field(item, field)
      item.try(field.to_s.to_sym) || 
      item.try(field.to_s.underscore.to_sym)
    end #def
    
    ######################################################################################
    # placeholder
    ######################################################################################
    def placeholder
      "#{DELIMITERS[0]}#{@name.to_s.upcase}#{DELIMITERS[1]}"
    end #def
    
    ######################################################################################
    # sanitize
    ######################################################################################
    def sanitize(text)
      # if we get some object, which is not a string, Numeric or the like
      # f.i. a Hash or an Arry or a CollectionProxy or an image then return @key to avoid
      # uggly errors
      return @key.to_s if text.respond_to?(:each)
      text = html_escape(text)
      text = odf_linebreak(text)
      text
    end #def
    
    HTML_ESCAPE = { '&' => '&amp;',  '>' => '&gt;',   '<' => '&lt;', '"' => '&quot;' }
    
    def html_escape(s)
      return "" unless s
      s.to_s.gsub(/[&"><]/) { |special| HTML_ESCAPE[special] }
    end #def
    
    def odf_linebreak(s)
      return "" unless s
      s = s.encode(universal_newline: true)
      s.to_s.gsub("\n", "<text:line-break/>").gsub("<br.*?>", "<text:line-break/>")
    end #def
    
  end #class
end #module
