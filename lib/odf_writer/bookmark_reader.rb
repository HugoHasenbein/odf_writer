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
  # BookmarkReader: find all bookmarks and set name
  #
  ########################################################################################
  class BookmarkReader
    
    attr_accessor :name
    
    ######################################################################################
    #
    # initialize
    #
    ######################################################################################
    def initialize(opts={})
      @name = opts[:name]
    end #def
    
    ######################################################################################
    #
    # get_paths: limit to paths with ancestors 'text '(content.xml) and master-styles (styles.xml)
    #
    ######################################################################################
    def paths( root, doc)
      
      # find nodes with matching field elements matching [BOOKMARK] pattern
      nodes = doc.xpath("//*[self::text:bookmark or self::text:bookmark-start]").select{|node| scan(node).present? }
      
      # find path for each field
      paths = nil
      nodes.each do |node|
        leaf  = {:bookmarks => scan(node)}
        paths = PathFinder.trail(node, leaf, :root => root, :paths => paths)
      end #each
      paths.to_h
      
    end #def
    
    ######################################################################################
    # private
    ######################################################################################
    
    private
    
    def scan(node)
      if name 
        node.attr("text:name") == name.upcase ? [node.attr("text:name")] : []
      else
        [node.attr("text:name")]
      end
    end #def
    
  end #class
end #module
