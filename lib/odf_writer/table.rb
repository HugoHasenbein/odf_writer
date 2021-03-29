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
  # Table: poulate and grow tables
  #
  ########################################################################################
  class Table
  
    include Nested
    
    attr_accessor :name, :collection, :proc
    
    ######################################################################################
    #
    # initialize
    #
    ######################################################################################
    def initialize(options)
      @name          = options[:name]
      @field         = options[:field]
      @collection    = options[:collection]
      @proc          = options[:proc]
      @key           = @field || @name
         
      @fields        = []
      @texts         = []
      @tables        = []
      @images        = []
      @bookmarks     = []
      
      @template_rows = []
      @header        = options[:header] || false
      @skip_if_empty = options[:skip_if_empty] || false
      
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
      
      @collection = items(row, @key, @proc) if row
      
      if @skip_if_empty && @collection.empty?
        table.remove
        return
      end
      
      @collection.each do |item|
      
        new_node = get_next_row
        #
        # experimental: new node must be added to doc prior to replace!
        #               else new_section does not have a name space
        #
        table.add_child(new_node)
        
        @tables.each    { |t| t.replace!(new_node, manifest, file, item) }
        @texts.each     { |t| t.replace!(new_node, item) }
        @fields.each    { |f| f.replace!(new_node, item) }
        @images.each    { |f| f.replace!(new_node, manifest, file, item) }
        
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
