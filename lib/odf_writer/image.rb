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
  # Image: replace images
  #
  ########################################################################################
  class Image < Field
  
    ######################################################################################
    #
    # constants
    #
    ######################################################################################
    IMAGE_DIR_NAME = "Pictures"
    
    ######################################################################################
    #
    # replace!
    #
    ######################################################################################
    def replace!(doc, manifest, template, item=nil )
    
      image_data = value(item)
      
      if is_image?(image_data) 
        
        # find placeholder image
        nodes = find_image_nodes( doc )
        return if nodes.blank?
        
        # find manifest
        man = manifest.xpath("//manifest:manifest") rescue nil
        return if man.blank?
        
        # each placeholder image
        nodes.each do |node|
        
          # create unique filename for image in .odt file
          path = ::File.join(IMAGE_DIR_NAME, "#{SecureRandom.hex(20).upcase}#{::File.extname(image_data[:filename])}")
          mime = Rack::Mime.mime_type(File.extname(image_data[:filename]))
          
          # set path and mime type of placeholder image
          node.attribute('href').value = path
          if node.attribute('mime-type').present?
            node.attribute('mime-type').value = mime
          else
            node.set_attribute('mime-type', mime)
          end
          
          # set width and height of placeholder image
          parent = node.parent
          if parent.name == "frame"
            width  = parent.attribute('width').value
            height = parent.attribute('height').value
            parent.attribute('height').value = recalc_height(:x => image_data[:width], :y => image_data[:height], :newx => width, :newy => height)
          end
          
          # add image to .odt file
          add_image_file( image_data[:bytes], path, mime, doc, man, template )
          
        end
      end
      
    end #def
    
    def self.unique_image_names(doc)
      nodes   = doc.xpath("//draw:frame[@draw:name='#{@name}']")
      padding = Math.log10(nodes.length).to_i + 1 if nodes.present?
      nodes.each_with_index do |node, i|
        num = "%.#{padding}i" % i
        node.attribute('name').value = "IMAGE_#{num}_" + node.attribute('name').value
      end
    end #def
    
    ######################################################################################
    #
    # private
    #
    ######################################################################################
    private
    
    ######################################################################################
    # is_image?
    ######################################################################################
    def is_image?(obj)
      obj.is_a?(Hash) && (obj.keys & [:filename, :width, :height, :bytes]).length == 4
    end #def
    
    ######################################################################################
    # find_image_nodes
    ######################################################################################
    def find_image_nodes(doc)
      doc.xpath(".//draw:frame[@draw:name='#{@name}']/draw:image")
    end #def
    
    ######################################################################################
    # recalc_height
    ######################################################################################
    def recalc_height(nums)
    
      numericals = {}
      dimensions = {}
      
      #remove dimensions like 'px' or 'cm' or 'in' or 'pt'
      [:x, :y, :newx, :newy].each do |v|
        num = nums[v].to_s.match(/[0-9.]+/)
        numericals[v] = num[0].to_f if num
        dimensions[v] = nums[v].to_s.gsub(/\A[0-9.]+/, "")
      end
      
      if [:x, :y, :newx, :newy].all?{|i| numericals[i].present? }
        y = numericals[:newx] / numericals[:x] * numericals[:y]
      end 
      
      y ? "#{'%.3f'%y}#{dimensions[:newy]}" : nums[:newy]
      
    end #def
    
    ######################################################################################
    # add_image_file
    ######################################################################################
    def add_image_file(bytes, path, mime, doc, manifest, template )
    
      file_entry = Nokogiri::XML::Node.new('manifest:file-entry', doc)
      file_entry.set_attribute('manifest:full-path', path)
      file_entry.set_attribute('manifest:media-type', mime)
      manifest.children.after file_entry
          
      template.output_stream.put_next_entry(path)
      template.output_stream.write bytes
      
    end #def
    
    
  end #class
end #module
