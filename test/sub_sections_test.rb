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
    attr_accessor :name, :sid, :children, :subs
    def initialize(_name, _sid, _children=[], _subs=[])
      @name=_name
      @sid=_sid
      @children=_children
      @subs=_subs
    end
  end



    subs1 = []
    subs1 << Item.new("SAWYER", 1, %w(Your bones don't break))
    subs1 << Item.new("HURLEY", 2, %w(Your cells react to bacteria and viruses))
    subs1 << Item.new("LOCKE",  3, %W(Do you see any Teletubbies in here))

    subs2 = []
    subs2 << Item.new("SLOANE",  21, %w(Praesent hendrerit lectus sit amet))
    subs2 << Item.new("JACK",    22, %w(Donec nec est eget dolor laoreet))
    subs2 << Item.new("MICHAEL", 23, %W(Integer elementum massa at nulla placerat varius))

    @items = []
    @items << Item.new("LOST",           '007', [], subs1)
    @items << Item.new("GREY'S ANATOMY", '220', nil)
    @items << Item.new("ALIAS",          '302', nil, subs2)
    @items << Item.new("BREAKING BAD",   '556', [])


    document = ODFWriter::Document.new("test/templates/test_sub_sections.odt") do |r|

      r.add_field("TAG_01", Time.now)
      r.add_field("TAG_02", "TAG-2 -> New tag")

      r.add_section("SECTION_01", @items) do |s|

        s.add_field('NAME') { |i| i.name }

        s.add_field('SID', :sid)

        s.add_section('SUB_01', :subs) do |r|
          r.add_field("FIRST_NAME", :name)
          r.add_table('IPSUM_TABLE', :children, :header => true) do |t|
            t.add_column('IPSUM_ITEM') { |i| i }
          end
        end

      end

    end

    document.generate("test/result/test_sub_sections.odt")
