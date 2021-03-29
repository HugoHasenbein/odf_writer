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
  # Section: poulate and grow sections
  #
  ########################################################################################
  class Section
    include Nested
    
    attr_accessor :name, :collection, :proc
    
    ######################################################################################
    #
    # initialize
    #
    ######################################################################################
    def initialize(options)
      @name       = options[:name]
      @field      = options[:field]
      @key        = @field || @name
      @collection = options[:collection]
      @proc       = options[:proc]
      
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
      
      @collection = items(row, @key, @proc) if row
      
      @collection.each do |item|
      
        new_section = get_section_node
        #
        # experimental: new node must be added to doc prior to replace!
        #               else new_section does not have a name space
        #
        @section_node.before(new_section) 
        
        @tables.each    { |t| t.replace!(new_section, manifest, file, item) }
        @sections.each  { |s| s.replace!(new_section, manifest, file, item) }
        @texts.each     { |t| t.replace!(new_section, item) }
        @fields.each    { |f| f.replace!(new_section, item) }
        @bookmarks.each { |b| b.replace!(new_section, item) }
        @images.each    { |b| b.replace!(new_section, manifest, file, item) }
        
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
