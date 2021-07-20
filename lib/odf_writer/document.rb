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
    def initialize(path = nil, zip_stream: nil, &block)
    
      @template = ODFWriter::Template.new(path, :zip_stream => zip_stream)
      
      @fields           = {}
      @field_readers    = {}
      
      @texts            = {}
      @text_readers     = {}
      
      @bookmarks        = {}
      @bookmark_readers = {}
      
      @images           = {}
      @image_readers    = {}
      
      @tables           = {}
      @table_readers    = {}
      
      @sections         = {}
      @section_readers  = {}
      
      @styles           = {}
      @list_styles      = {}
      
      if block_given?
        instance_eval(&block)
      end
      
    end #def
    
    ######################################################################################
    #
    # add_readers
    #
    ######################################################################################
    def add_readers(files = ODFWriter::Template::CONTENT_FILES.keys)
      files.each do |file|
        add_bookmark_reader(file)
        add_field_reader(file)
        add_text_reader(file)
        add_image_reader(file)
        add_section_reader(file)
        add_table_reader(file)
      end
    end #def
    
    ######################################################################################
    #
    # add_field
    #
    ######################################################################################
    def add_field(file, name, opts={}, &block)
      opts.merge!(:name => name)
      @fields[file] ||= []; @fields[file] << Field.new(opts, &block)
    end #def
    
    ######################################################################################
    #
    # add_field_reader
    #
    ######################################################################################
    def add_field_reader(file, name=nil)
      @field_readers[file] ||= []; @field_readers[file] << FieldReader.new(:name => name)
    end #def
    
    ######################################################################################
    #
    # add_text
    #
    ######################################################################################
    def add_text(file, name, opts={}, &block)
      opts.merge!(:name => name)
      @texts[file] ||= []; @texts[file] << Text.new(opts, &block)
    end #def
    
    ######################################################################################
    #
    # add_text_reader
    #
    ######################################################################################
    def add_text_reader(file, name=nil)
      @text_readers[file] ||= []; @text_readers[file] << TextReader.new(:name => name)
    end #def
    
    ######################################################################################
    #
    # add_bookmark
    #
    ######################################################################################
    def add_bookmark(file, name, opts={}, &block)
      opts.merge!(:name => name)
      @bookmarks[file] ||= []; @bookmarks[file] << Bookmark.new(opts, &block)
    end #def
    
    ######################################################################################
    #
    # add_bookmark_reader
    #
    ######################################################################################
    def add_bookmark_reader(file, name=nil)
      @bookmark_readers[file] ||= []; @bookmark_readers[file] << BookmarkReader.new(:name => name)
    end #def
    
    ######################################################################################
    #
    # add_image
    #
    ######################################################################################
    def add_image(file, name, opts={}, &block)
      opts.merge!(:name => name)
      @images[file] ||= []; @images[file] << Image.new(opts, &block)
    end #def
    
    ######################################################################################
    #
    # add_image_reader
    #
    ######################################################################################
    def add_image_reader(file, name=nil)
      @image_readers[file] ||= []; @image_readers[file] << ImageReader.new(:name => name)
    end #def
    
    ######################################################################################
    #
    # add_table
    #
    ######################################################################################
    def add_table(file, name, collection, opts={})
      opts.merge!(:name => name, :collection => collection)
      table = Table.new(opts)
      @tables[file] ||= []; @tables[file] << table
      yield(table)
    end #def
    
    ######################################################################################
    #
    # add_table_reader
    #
    ######################################################################################
    def add_table_reader(file, name=nil)
      @table_readers[file] ||= []; @table_readers[file] << TableReader.new(:name => name)
    end #def
    
    ######################################################################################
    #
    # add_section
    #
    ######################################################################################
    def add_section(file, name, collection, opts={})
      opts.merge!(:name => name, :collection => collection)
      section = Section.new(opts)
      @sections[file] ||= []; @sections[file] << section
      yield(section)
    end #def
    
    ######################################################################################
    #
    # add_section_reader
    #
    ######################################################################################
    def add_section_reader(file, name=nil)
      @section_readers[file] ||= []; @section_readers[file] << SectionReader.new(:name => name)
    end #def
    
    ######################################################################################
    #
    # add_style
    #
    ######################################################################################
    def add_style(root, *styles )
      @styles[root] ||= []; @styles[root] << Style.new( *styles )
    end #def
    
    ######################################################################################
    #
    # add_list_style
    #
    ######################################################################################
    def add_list_style(root, *list_styles )
      list_styles.each do |list_style|
        @list_styles[root] ||= []; @list_styles[root] << ListStyle.new( list_style )
      end
    end #def
    
    ######################################################################################
    #
    # tree
    #
    ######################################################################################
    def tree
      results = {}
      @template.content do |file, doc|
       #results.deep_merge!( leafs( file, doc)) # requires Rails
        results = deep_merge(results, leafs( file, doc))
      end
      results
    end #def
    
    ######################################################################################
    #
    # leafs
    #
    ######################################################################################
    def leafs( file, doc)
      results={}
# requires Rails
#       results.deep_merge! @bookmark_readers[file].map { |r| r.paths(file, doc) }.inject{|m,n| m.deep_merge(n){|k, v1,v2| v1 + v2}} if @bookmark_readers[file]
#       results.deep_merge! @field_readers[file].map    { |r| r.paths(file, doc) }.inject{|m,n| m.deep_merge(n){|k, v1,v2| v1 + v2}} if @field_readers[file]
#       results.deep_merge! @text_readers[file].map     { |r| r.paths(file, doc) }.inject{|m,n| m.deep_merge(n){|k, v1,v2| v1 + v2}} if @text_readers[file]
#       results.deep_merge! @image_readers[file].map    { |r| r.paths(file, doc) }.inject{|m,n| m.deep_merge(n){|k, v1,v2| v1 + v2}} if @image_readers[file]

        results = deep_merge( results, @bookmark_readers[file].map { |r| r.paths(file, doc) }.inject{|m,n| deep_merge(m, n)} ) if @bookmark_readers[file]
        results = deep_merge( results, @field_readers[file].map    { |r| r.paths(file, doc) }.inject{|m,n| deep_merge(m, n)} ) if @field_readers[file]
        results = deep_merge( results, @text_readers[file].map     { |r| r.paths(file, doc) }.inject{|m,n| deep_merge(m, n)} ) if @text_readers[file]
        results = deep_merge( results, @image_readers[file].map    { |r| r.paths(file, doc) }.inject{|m,n| deep_merge(m, n)} ) if @image_readers[file]
      results
    end #def
    
    ######################################################################################
    #
    # populate
    #
    ######################################################################################
    def populate(object, options={})
    
      file = options[:file] || :content
      coll = options[:coll] || []
      tree = options[:tree] || self.tree
      prok = options[:proc]
      list = options[:list]; list = Array(list).compact
      
      tree.each do |key, names|
        case key
        when :fields
          names.each do |name|
            add_field(file, name, :value => prok ? prok.call(object, name) : object.try(name.downcase.to_sym))
          end #def
        when :texts
          names.each do |name|
            add_text(file, name, :value => prok ? prok.call(object, name) : object.try(name.downcase.to_sym))
          end #def
        when :bookmarks
          names.each do |name|
            add_bookmark(file, name, :value => prok ? prok.call(object, name) : object.try(name.downcase.to_sym))
          end #def
        when :images
          names.each do |name|
            add_image(file, name, :value => (prok ? prok.call(object, name) : object.try(name.downcase.to_sym)))
          end #def
        when :tables
          names.each do |name, table_tree|
            if list.include?(name)
              add_table(file, name, coll, options){|table| table.populate(table_tree, options)}
            elsif object.respond_to?(name.underscore.to_sym)
              add_table(file, name, arrify(object.send(name.underscore.to_sym)), options){|table| table.populate(table_tree, options)}
            end
          end #def
        when :sections
          names.each do |name, section_tree|
            if list.include?(name)
              add_section(file, name, coll, options){|section| section.populate(section_tree, options)} if list.include?(name)
            elsif object.respond_to?(name.underscore.to_sym)
              add_section(file, name, arrify(object.send(name.underscore.to_sym)), options){|section| section.populate(section_tree, options)}
            end
          end #def
        when :files
          names.each do |file, file_tree|
            populate(object, options.merge(:file => file, :tree => file_tree))
          end
        end #case
      end #each
    end #def
    
    ######################################################################################
    #
    # write
    #
    ######################################################################################
    def write(dest = nil)
    
      @template.update_content do |template|
      
        template.update_files do |file, doc, manifest|
        
          @styles[file].to_a.each      { |s| s.add_style(doc) }
          @list_styles[file].to_a.each { |s| s.add_list_style(doc)  }
          
          @sections[file].to_a.each    { |s| s.replace!(doc, manifest, template)  }
          @tables[file].to_a.each      { |t| t.replace!(doc, manifest, template)  }
          
          @texts[file].to_a.each       { |t| t.replace!(doc)  }
          @fields[file].to_a.each      { |f| f.replace!(doc)  }
          
          @bookmarks[file].to_a.each   { |b| b.replace!(doc)  }
          @images[file].to_a.each      { |i| i.replace!(doc, manifest, template) }
          
          Image.unique_image_names( doc ) if @images.present?
        end
        
      end
      
      if dest
        ::File.open(dest, "wb") {|f| f.write(@template.data) }
      else
        @template.data
      end
      
    end #def
    
    ######################################################################################
    #
    # private
    #
    ######################################################################################
    private
    
    # deep_merge without using Rails
    def deep_merge(left, right)
        merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : [:undefined, nil, :nil].include?(v2) ? v1 : v1 + v2 }
        left.merge(right, &merger)
    end #def
    
    def arrify(obj)
      case obj
      when Array
        obj
      when Hash
        [obj]
      else
        obj.respond_to?(:to_a) ? obj.to_a : [obj]
      end
    end #def
    
  end #class
end #module
