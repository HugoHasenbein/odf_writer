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

require 'rubygems'
require 'zip'
require 'fileutils'
require 'nokogiri'

require File.expand_path('../odf_writer/parser/default',  __FILE__)
require File.expand_path('../odf_writer/path_finder',     __FILE__)

require File.expand_path('../odf_writer/nested',          __FILE__)
require File.expand_path('../odf_writer/field',           __FILE__)
require File.expand_path('../odf_writer/field_reader',    __FILE__)
require File.expand_path('../odf_writer/text',            __FILE__)
require File.expand_path('../odf_writer/text_reader',     __FILE__)
require File.expand_path('../odf_writer/bookmark',        __FILE__)
require File.expand_path('../odf_writer/bookmark_reader', __FILE__)
require File.expand_path('../odf_writer/image',           __FILE__)
require File.expand_path('../odf_writer/image_reader',    __FILE__)
require File.expand_path('../odf_writer/table',           __FILE__)
require File.expand_path('../odf_writer/table_reader',    __FILE__)
require File.expand_path('../odf_writer/section',         __FILE__)
require File.expand_path('../odf_writer/section_reader',  __FILE__)
require File.expand_path('../odf_writer/images',          __FILE__)
require File.expand_path('../odf_writer/template',        __FILE__)
require File.expand_path('../odf_writer/document',        __FILE__)
require File.expand_path('../odf_writer/style',           __FILE__)
require File.expand_path('../odf_writer/list_style',      __FILE__)
