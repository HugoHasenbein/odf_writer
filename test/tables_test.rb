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

require './lib/odf_writer'
require 'ostruct'
require 'faker'
require 'launchy'


    @col1 = []
    (1..40).each do |i|
      @col1 << {:name=>"name #{i}",  :idx=>i,  :address=>"this is address #{i}"}
    end


    @col2 = []
    @col2 << OpenStruct.new({:name=>"josh harnet",   :idx=>"02", :address=>"testing <&> ",                 :phone=>99025668, :zip=>"90420-002"})
    @col2 << OpenStruct.new({:name=>"sandro duarte", :idx=>"45", :address=>"address with &",               :phone=>88774451, :zip=>"90490-002"})
    @col2 << OpenStruct.new({:name=>"ellen bicca",   :idx=>"77", :address=>"<address with escaped html>",  :phone=>77025668, :zip=>"94420-002"})
    @col2 << OpenStruct.new({:name=>"luiz garcia",   'idx'=>"88", :address=>"address with\nlinebreak",      :phone=>27025668, :zip=>"94520-025"})

    @col3, @col4, @col5 = [], [], []



    document = ODFWriter::Document.new("test/templates/test_tables.odt") do |r|

      r.add_field("HEADER_FIELD", "This field was in the HEADER")

      r.add_field("TAG_01", "New tag")
      r.add_field("TAG_02", "TAG-2 -> New tag")

      r.add_table("TABLE_01", @col1, :header=>true) do |t|
        t.add_column(:field_01, :idx)
        t.add_column(:field_02, :name)
        t.add_column(:address)
      end

      r.add_table("TABLE_02", @col2) do |t|
        t.add_column(:field_04, :idx)
        t.add_column(:field_05, :name)
        t.add_column(:field_06, 'address')
        t.add_column(:field_07, :phone)
        t.add_column(:field_08, :zip)
      end

      r.add_table("TABLE_03", @col3, :header=>true) do |t|
        t.add_column(:field_01, :idx)
        t.add_column(:field_02, :name)
        t.add_column(:field_03, :address)
      end

      r.add_table("TABLE_04", @col4, :header=>true, :skip_if_empty => true) do |t|
        t.add_column(:field_01, :idx)
        t.add_column(:field_02, :name)
        t.add_column(:field_03, :address)
      end

      r.add_table("TABLE_05", @col5) do |t|
        t.add_column(:field_01, :idx)
        t.add_column(:field_02, :name)
        t.add_column(:field_03, :address)
      end

      r.add_image("graphics1", File.join(Dir.pwd, 'test', 'templates', 'piriapolis.jpg'))
      r.add_image("graphics2", File.join(Dir.pwd, 'test', 'templates', 'rails.png'))

    end

    document.generate("test/result/test_tables.odt")
