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


  class Item
    attr_accessor :name, :mail
    def initialize(_name,  _mail)
      @name=_name
      @mail=_mail
    end
  end



    @items = []
    50.times { @items << Item.new(Faker::Name.name, Faker::Internet.email) }



    document = ODFWriter::Document.new("test/templates/test_table_headers.odt") do |r|

      r.add_table("TABLE_01", @items, :header => true) do |s|
        s.add_column(:name)
        s.add_column(:mail)
      end

      r.add_table("TABLE_02", @items, :header => true) do |s|
        s.add_column(:name)
        s.add_column(:mail)
      end

      r.add_table("TABLE_03", @items) do |s|
        s.add_column(:name)
        s.add_column(:mail)
      end

    end

    document.generate("test/result/test_table_headers.odt")
