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
  # SectionReader: find all sections and set name
  #
  ########################################################################################
  class SectionReader
    
    attr_accessor :name
    
    ######################################################################################
    #
    # initialize
    #
    ######################################################################################
    def initialize(opts)
      @name = opts[:name]
    end #def
    
    ######################################################################################
    #
    # sections
    #
    ######################################################################################
    def sections( doc )
      nodes( doc ).keys
    end #def
    
    ######################################################################################
    #
    # nodes
    #
    ######################################################################################
    def nodes( doc )
      doc.xpath(".//text:section").map{|node| [node.attr("text:name"), node] }.to_h
    end #def
    
  end #class
end #module
