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
require 'launchy'


  class Item
    attr_accessor :name, :sid, :children
    def initialize(_name, _sid, _children=[])
      @name=_name
      @sid=_sid
      @children=_children
    end
  end

    @items = []
    @items << Item.new("LOST",           '007', %w(sawyer juliet hurley locke jack freckles))
    @items << Item.new("ALIAS",          '302', %w(sidney sloane jack michael marshal))
    @items << Item.new("GREY'S ANATOMY", '220', %w(meredith christina izzie alex george))
    @items << Item.new("BREAKING BAD",   '556', %w(pollos gus mike heisenberg))


    document = ODFWriter::Document.new("test/templates/test_nested_tables.odt") do |r|

      r.add_field("TAG_01", Time.now)
      r.add_field("TAG_02", "TAG-2 -> New tag")

      r.add_table("TABLE_MAIN", @items) do |s|

        s.add_column('NAME') { |i| i.name }

        s.add_column('SID', :sid)

        s.add_table('TABLE_S1', :children, :header=>true) do |t|
          t.add_column('NAME1') { |item| "-> #{item}" }
          t.add_column('INV')   { |item| item.to_s.reverse.upcase }
        end

      end

    end

    document.generate("test/result/test_nested_tables.odt")
