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

RSpec.describe "Templates Types" do

  before(:each) do

    @field_01 = Faker::Company.name
    @field_02 = Faker::Name.name

    document.add_field(:field_01, @field_01)
    document.add_field(:field_02, @field_02)

    document.generate("spec/result/specs.odt")

    @data = Inspector.new("spec/result/specs.odt")

  end

  context "template from file" do
    let(:document) { ODFWriter::Document.new("spec/specs.odt") }

    it "works" do

      expect(@data.text).not_to match(/\[FIELD_01\]/)
      expect(@data.text).not_to match(/\[FIELD_02\]/)

      expect(@data.text).to match @field_01
      expect(@data.text).to match @field_02

    end
  end

  context "template from a String" do
    let(:document) { ODFWriter::Document.new(io: ::File.open("spec/specs.odt").read) }

    it "works" do

      expect(@data.text).not_to match(/\[FIELD_01\]/)
      expect(@data.text).not_to match(/\[FIELD_02\]/)

      expect(@data.text).to match @field_01
      expect(@data.text).to match @field_02

    end
  end

end
