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
require 'faker'


  class Item
    attr_accessor :name, :inner_text
    def initialize(_name,  _text)
      @name=_name
      @inner_text=_text
    end
  end



    @items = []
    3.times do

      text = <<-HTML
        <p>#{Faker::Lorem.sentence} <em>#{Faker::Lorem.sentence}</em> #{Faker::Lorem.sentence}</p>
        <p>#{Faker::Lorem.sentence} <strong>#{Faker::Lorem.paragraph(3)}</strong> NO FORMAT <strong>#{Faker::Lorem.paragraph(2)}</strong> #{Faker::Lorem.sentence}</p>
        <p>#{Faker::Lorem.paragraph}</p>
        <blockquote>
          <p>#{Faker::Lorem.paragraph}</p>
          <p>#{Faker::Lorem.paragraph}</p>
        </blockquote>
        <p style="margin: 150px">#{Faker::Lorem.paragraph}</p>
        <p>#{Faker::Lorem.paragraph}</p>
      HTML

      @items << Item.new(Faker::Name.name, text)

    end


    item = @items.pop

    document = ODFWriter::Document.new("test/templates/test_text.odt") do |r|

      r.add_field("TAG_01", Faker::Company.name)
      r.add_field("TAG_02", Faker::Company.catch_phrase)

      r.add_text(:main_text, item.inner_text)

      r.add_section("SECTION_01", @items) do |s|
        s.add_field(:name)
        s.add_text(:inner_text) { |i| i.inner_text }
      end

      r.add_table("TABLE", @items) do |s|
        s.add_field(:field, :name)
        s.add_text(:text, :inner_text)
      end

    end

    document.generate("test/result/test_text.odt")
