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
  # FieldReader: find all fields and set name
  #
  ########################################################################################
  class FieldReader
    
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
    # paths
    #
    ######################################################################################
    def paths( file, doc)
      
      # find nodes with matching field elements matching [FIELD] pattern
      nodes = doc.xpath("//text()").select{|node| scan(node).present? }
      

      # find path for each field
      paths = nil
      nodes.each do |node|
        leaf  = {:fields => scan(node)}
        paths = PathFinder.trail(node, leaf, :root => file, :paths => paths)
      end #each
      paths.to_h
      
    end #def
    
    ######################################################################################
    # private
    ######################################################################################
    
    private
    
    def scan(node)
      if name 
        node.text.scan(/(?<=#{Regexp.escape Field::DELIMITERS[0]})#{name.upcase}(?=#{Regexp.escape Field::DELIMITERS[1]})/)
      else
        node.text.scan(/(?<=#{Regexp.escape Field::DELIMITERS[0]})[A-Z0-9_]+?(?=#{Regexp.escape Field::DELIMITERS[1]})/)
      end
    end #def
    
   end #class
end #module
