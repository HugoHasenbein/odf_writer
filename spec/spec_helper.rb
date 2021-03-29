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

I18n.enforce_available_locales = false

class Item
  attr_accessor :id, :name, :subs
  def initialize(_id, _name, _subs=[])
    @name = _name
    @id   = _id
    @subs = _subs
  end

  def self.get_list(quant = 3)
    r = []
    (1..quant).each do |i|
      r << Item.new(Faker::Number.number(10), Faker::Name.name)
    end
    r
  end

end

class Inspector

  def initialize(file)
    @content = nil
    Zip::File.open(file) do |f|
      @content = f.get_entry('content.xml').get_input_stream.read
    end
  end

  def xml
    @xml ||= Nokogiri::XML(@content)
  end

  def text
    @text ||= xml.to_s
  end

end

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
end
