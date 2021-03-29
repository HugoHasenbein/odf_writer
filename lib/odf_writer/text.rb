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
  # Text: replace text items
  #
  ########################################################################################
  class Text < Field
  
    ######################################################################################
    #
    # constants
    #
    ######################################################################################
    DELIMITERS = %w({ })
    
    ######################################################################################
    #
    # replace!
    #
    ######################################################################################
    def replace!(content, item = nil)
    
      return unless node = find_text_node(content)
      
      text = value(item)
      
      @parser = Parser::Default.new(text, node, 
        :doc                 => content,
        :remove_classes      => @remove_classes,
        :remove_class_prefix => @remove_class_prefix,
        :remove_class_suffix => @remove_class_suffix
      )
      
      @parser.paragraphs.each do |p|
        node.before(p)
      end
      
      node.remove
      
    end #def
    
    ######################################################################################
    #
    # private
    #
    ######################################################################################
    private
    
    ######################################################################################
    # find_text_node
    ######################################################################################
    def find_text_node(doc)
      texts = doc.xpath(".//text:p[text()='#{placeholder}']")
      if texts.empty?
        texts = doc.xpath(".//text:p/text:span[text()='#{placeholder}']")
        if texts.empty?
          texts = nil
        else
          texts = texts.first.parent
        end
      else
        texts = texts.first
      end
      
      texts
    end #def
    
    ######################################################################################
    # placeholder
    ######################################################################################
    def placeholder
      "#{DELIMITERS[0]}#{@name.to_s.upcase}#{DELIMITERS[1]}"
    end #def
  end #class
end #module
