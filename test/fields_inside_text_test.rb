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


    @html = <<-HTML
      <p>Uniquely promote installed base total linkage via emerging deliverables com <strong>[EVENTO_TEXTO_CARTA]</strong>, unleash cross-media collaboration <strong>[FUNCAO]</strong> [EVENTO_NOME].</p>

      <p>Progressively fashion diverse portals nº <strong>[NUMERO_SECAO]</strong> do local <strong>[NOME_LOCAL]</strong>, situado na <strong>[ENDERECO_LOCAL]</strong> methodologies </p>

      <p>Assertively orchestrate market positioning bandwidth rather than fully researched total linkage. Interactively architect granular e-markets via clicks-and-mortar ROI. Uniquely aggregate compelling.</p>

      <p>Compellingly facilitate functionalized interfaces before wireless models. Compellingly morph parallel systems whereas combinado com o artigo 63, § 2º da Lei nº 9.504/97, abaixo mencionados:</p>

      <p style="margin-left:1.76cm;"><em>Art. 120 - § 1º Compellingly envisioneer high standards in niches without best-of-breed leadership. Phosfluorescently unleash go forward methodologies after bricks-and-clicks niches. Authoritatively. </em></p>

      <p style="margin-left:1.76cm;"><em>Art. 63 - [...] § 2º Enthusiastically parallel task user friendly functionalities whereas exceptional leadership. </em></p>

      <p>Credibly enable multifunctional strategic theme areas and premium communities.</p>

    HTML



    document = ODFWriter::Document.new("test/templates/test_fields_inside_text.odt") do |r|

      r.add_text(:body, @html)

      r.add_field('EVENTO_TEXTO_CARTA', Faker::Lorem.sentence)
      r.add_field('FUNCAO', Faker::Lorem.word)
      r.add_field('EVENTO_NOME', Faker::Company.name)

      r.add_field('NUMERO_SECAO', Faker::Number.number(3))
      r.add_field('NOME_LOCAL', Faker::Company.name)
      r.add_field('ENDERECO_LOCAL', Faker::Address.street_address)
    end

    document.generate("test/result/test_fields_inside_text.odt")
