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
  # Nested: provide data to nestable items
  #
  ########################################################################################
  module Nested
  
    def add_field(name, options={}, &block)
      options.merge!(:name => name)
      @fields << Field.new(options, &block)
    end #def
    alias_method :add_column, :add_field
    
    def add_text(name, options={}, &block)
      options.merge!(:name => name)
      @texts << Text.new(options, &block)
    end #def
    
    def add_bookmark(name, options={}, &block)
      options.merge!(:name => name)
      @bookmarks << Bookmark.new(options, &block)
    end #def
    
    def add_image(name, options={}, &block)
      options.merge!(:name => name)
      @images << Image.new(options, &block)
    end #def
    
    def add_table(name, options={})
      options.merge!(:name => name)
      tab = Table.new(options)
      @tables << tab
      yield(tab)
    end #def
    
    def add_section(name, options={})
      options.merge!(:name => name)
      sec = Section.new(options)
      @sections << sec
      yield(sec)
    end #def
    
    ######################################################################################
    # populate
    ######################################################################################
    def populate(tree, options={})
      
      tree.to_h.each do |key, names|
        case key
        when :fields
          names.each do |name|
            add_field(name, options)
          end #def
        when :texts
          names.each do |name|
            add_text(name, options)
          end #def
        when :bookmarks
          names.each do |name|
            add_bookmark(name, options)
          end #def
        when :images
          names.each do |name|
            add_image(name, options)
          end #def
        when :tables
          names.each do |name, table_tree|
            add_table(name, options){|table| table.populate(table_tree, options)}
          end #def
        when :sections
          names.each do |name, section_tree|
            add_section(name, options){|section| section.populate(section_tree, options)}
          end #def
        end #case
      end #each
    end #def
    
    ######################################################################################
    # items: get item collection form item
    ######################################################################################
    def items(item, field, procedure)
    
      ####################################################################################
      # call proc before other alternatives
      ####################################################################################
      return arrify(procedure.call(item, field)) if procedure
      
      ####################################################################################
      # item class dependend call
      ####################################################################################
      return arrify(hash_value(item, field)) if item.is_a?(Hash)
      
      ####################################################################################
      # field class dependend call
      ####################################################################################
      case field
        
      when String, Symbol
        if item.respond_to?(field.to_s.to_sym)
          arrify(item.send(field.to_s.to_sym))
          
        elsif item.respond_to?(field.downcase.to_sym)
          arrify(item.send(field.downcase.to_sym))
          
        else
          []
        end
      else
        []
      end #case
    end #def
    
    ######################################################################################
    #
    # private
    #
    ######################################################################################
    private
    
    def hash_value(hash, key)
      hash[key.to_s]            || hash[key.to_sym] || 
      hash[key.to_s.underscore] || hash[key.to_s.underscore.to_sym]
    end #def
    
    def arrify(obj)
      return  obj      if obj.is_a?(Array)
      return [obj]     if obj.is_a?(Hash)
      return  obj.to_a if obj.respond_to?(:to_a)
      return [obj]
    end #def
    
  end #module
end #module
