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

RSpec.describe "Tables" do

  before(:context) do

    document = ODFWriter::Document.new("spec/specs.odt") do |r|

      r.add_table('TABLE_02', []) do |t|
        t.add_column(:column_01, :id)
        t.add_column(:column_02, :name)
      end

      r.add_table('TABLE_03', [], skip_if_empty: true) do |t|
        t.add_column(:column_01, :id)
        t.add_column(:column_02, :name)
      end

    end

    document.generate("spec/result/specs.odt")

    @data = Inspector.new("spec/result/specs.odt")

  end

  context "with Empty collection" do

    it "should not remove table" do
      table2 = @data.xml.xpath(".//table:table[@table:name='TABLE_02']")
      expect(table2).not_to be_empty
    end

    it "should remove table if required" do
      table3 = @data.xml.xpath(".//table:table[@table:name='TABLE_03']")
      expect(table3).to be_empty
    end

  end

end
