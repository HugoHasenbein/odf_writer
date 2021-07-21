# encoding: utf-8
#
# Ruby Gem to create a self populating Open Document Format (.odf) text file.
#
# Copyright © 2021 Stephan Wenzel <stephan.wenzel@drwpatent.de>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#

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
    
    def deep_fields(fs)
      fs.split(/\./)
    end #def
    
    def deep_try(item, f)
      deep_fields(f).inject(item) {|obj,f| obj.try(f.to_s.underscore.to_sym)}
    end #def
    
  end #class
end #module
