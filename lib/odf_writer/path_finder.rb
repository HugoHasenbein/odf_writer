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
  # PathFinder: find all fields and set name
  #
  ########################################################################################
  class PathFinder
  
    ######################################################################################
    #
    # constants
    #
    ######################################################################################
    IGNORE = {
      :fields    => /\A_/, 
      :texts     => /\A_/, 
      :bookmarks => /\A_/, 
      :images    => /\A_/, 
      :tables    => /\A_|\ATable/i,
      :sections  => /\A_|\ASection/i
    }.freeze
      
    class << self
      ####################################################################################
      #
      # trail: find path in odt document, whereby only sections and tabes are searched as ancestors
      #
      #        node: Nokogiri node
      #        leaf: hash, f.i. {:fields => ["NAME", "STREET", "ZIP", "PLACE"]}
      #        
      #        options:
      #                  :root   => :content | :styles, defaults to :root
      #                  :paths  => :auto vivifying-hash, defaults to it
      #
      ####################################################################################
      def trail( node, leaf, options={})
        
        # ignore
        ignore = IGNORE.merge(options[:ignore].to_h)
        
        # determine root
        root  = options[:root]  || :root
        
        # create auto-vivifying hash
        paths = options[:paths] || Hash.new { |h, k| h[k] = Hash.new(&h.default_proc)  }
        
        # for tables and sections add level with node name
        ancestors = node.ancestors.reverse.select{|ancestor| %w(section table).include?(ancestor.name)}
        
        path = [:files, root] + ancestors.map do |ancestor|
          filter_node(ancestor, ignore) 
        end.flatten #map
        
        # add each field in a nested hash
        paths.dig(*path)[leaf.keys.first]  = paths.dig(*path)[leaf.keys.first].presence || [] # cannot do '||=''
        paths.dig(*path)[leaf.keys.first] += filter_leafs(leaf, ignore)
        paths
       end #def
       
       ###################################################################################
       #
       # private
       #
       ###################################################################################
       private
       
       def filter_node(node, ignore)
         case node.name
         when "section"
           node.attr("text:name").to_s.match?(Regexp.new(ignore[:sections].to_s)) ? [] : [:sections, node.attr("text:name")]
         when "table"
           node.attr("table:name").to_s.match?(Regexp.new(ignore[:tables].to_s))  ? [] : [:tables,   node.attr("table:name")]
         else
           []
         end #case
       end #def
       
       def filter_leafs(leaf, ignore)
         case leaf.keys.first
         when :fields
           Array(leaf.values.first).select{|val| !val.match?(Regexp.new(ignore[:fields].to_s))}
         when :texts
           Array(leaf.values.first).select{|val| !val.match?(Regexp.new(ignore[:texts].to_s))}
         when :bookmarks
           Array(leaf.values.first).select{|val| !val.match?(Regexp.new(ignore[:bookmarks].to_s))}
         when :images
           Array(leaf.values.first).select{|val| !val.match?(Regexp.new(ignore[:images].to_s))}
         end #case
       end #def
     end #self
   end #class
end #module
