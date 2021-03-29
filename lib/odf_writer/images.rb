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
  # Images: replace images 
  #
  ########################################################################################
  module Images
  
    ######################################################################################
    #
    # constants
    #
    ######################################################################################
    IMAGE_DIR_NAME = "Pictures"
    
    ######################################################################################
    #
    # find_image_name_matches
    #
    ######################################################################################
    def find_image_name_matches(content)
    
      @images.each_pair do |image_name, img_data|
        if node = content.xpath("//draw:frame[@draw:name='#{image_name}']/draw:image").first
          placeholder_path = node.attribute('href').value
          @image_names_replacements[path] = ::File.join(IMAGE_DIR_NAME, ::File.basename(placeholder_path))
        end
      end
      
    end #def
    
    ######################################################################################
    #
    # include_image_files
    #
    ######################################################################################
    def include_image_files(file)
    
      return if @images.empty?
      
      @image_names_replacements.each_pair do |path, template_image|
      
        file.output_stream.put_next_entry(template_image)
        file.output_stream.write ::File.read(path)
        
      end
      
    end #def
    
    ######################################################################################
    #
    # avoid_duplicate_image_names
    #
    ######################################################################################
    # newer versions of LibreOffice can't open files with duplicates image names
    def avoid_duplicate_image_names(content)
    
      nodes = content.xpath("//draw:frame[@draw:name]")
      
      nodes.each_with_index do |node, i|
        node.attribute('name').value = "pic_#{i}"
      end
      
    end #def
    
  end #class
end #module
