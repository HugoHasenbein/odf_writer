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

module ODFWriter
  module Parser
  
    ######################################################################################
    #
    # Default: html parser and code translator
    #
    ######################################################################################
    class Default
    
      attr_accessor :paragraphs
      
      ####################################################################################
      #
      # constants
      #
      ####################################################################################
      INLINE       = %w(     a      span      strong      b      em      i      ins      u      del      strike      sub      sup     code)
      TEXTINLINE   = %w(text:a text:span text:strong text:b text:em text:i text:ins text:u text:del text:strike text:sub text:sup text:code)
     #SAFETAGS     = %w(h1 h2 h3 h4 h5 h6 p a br div span strong b em i ins u del strike sub sup code li ul ol th td tr tbody thead tfoot table )
      UNSAFETAGS   = %w(script style)
      
      #
      # table:      blank (white) cells, no borders,                 bold face,            
      # thrifty     blank (white) cells, no borders,                 normal face,          
      # tiny        blank (white) cells, no borders,                 tiny face,            
      # headmedium  blank (white) cells, header rows bottom borders, medium face           
      # listmedium  blank (white) cells, header rows bottom borders, medium face          , footer rows top-borders
      #
      # list:       blank (white) cells, header rows bottom borders, normal face,         , footer rows top-borders
      # boxes:      blank (white) cells, all borders,                normal face
      # invoice:    blank (white) cells, header rows bottom borders, header rows bold face, footer rows top-borders
      # caption:    blank (white) cells,                             bold face
      #
      # tc:      column width
      # tcs:     first column width and last column width
      #
      TABLECLASSES = %w(table thrifty tiny list headmedium listmedium boxes invoice caption) 
      TABLESTYLES  = {:table        => {:thead => {:ths => ["td", "td", "td"],             :tr => "tr", :tds => ["td", "td", "td"],               :fs => ["", "", ""],                   :ps => ["p", "p", "p"]  }, 
                                        :tbody => {:ths => ["td", "td", "td"],             :tr => "tr", :tds => ["td", "td", "td"],               :fs => ["", "", ""],                   :ps => ["p", "p", "p"]  }, 
                                        :tfoot => {:ths => ["td", "td", "td"],             :tr => "tr", :tds => ["td", "td", "td"],               :fs => ["", "", ""],                   :ps => ["p", "p", "p"]  }, 
                                        
                                        :tcs => ["tc", "tc", "tc"]
                                       },
                                        
                      :thrifty      => {:thead => {:ths => ["td", "td", "td"],             :tr => "tr", :tds => ["td", "td", "td"],               :fs => ["", "", ""],                   :ps => ["p", "p", "p"] }, 
                                        :tbody => {:ths => ["td", "td", "td"],             :tr => "tr", :tds => ["td", "td", "td"],               :fs => ["", "", ""],                   :ps => ["p", "p", "p"] }, 
                                        :tfoot => {:ths => ["td", "td", "td"],             :tr => "tr", :tds => ["td", "td", "td"],               :fs => ["", "", ""],                   :ps => ["p", "p", "p"] }, 
                                        
                                        :tcs => ["tc", "tc", "tc"]
                                       },
                                       
                      :tiny         => {:thead => {:ths => ["td", "td", "td"],             :tr => "tr", :tds => ["td", "td", "td"],               :fs => ["small", "small", "small"],    :ps => ["p", "p", "p"] }, 
                                        :tbody => {:ths => ["td", "td", "td"],             :tr => "tr", :tds => ["td", "td", "td"],               :fs => ["small", "small", "small"],    :ps => ["p", "p", "p"] }, 
                                        :tfoot => {:ths => ["td", "td", "td"],             :tr => "tr", :tds => ["td", "td", "td"],               :fs => ["small", "small", "small"],    :ps => ["p", "p", "p"] }, 
                                        
                                        :tcs => ["tc", "tc", "tc"]
                                       },
                                       
                      :list         => {:thead => {:ths => ["tdhead", "tdhead", "tdhead"], :tr => "tr", :tds => ["tdhead",  "tdhead", "tdhead"],  :fs => ["", "", ""],                   :ps => ["mono", "mono", "mono"]     }, 
                                        :tbody => {:ths => ["tdhead", "tdhead", "tdhead"], :tr => "tr", :tds => ["td",      "td"    , "td"],      :fs => ["", "", ""],                   :ps => ["", "", ""]     }, 
                                        :tfoot => {:ths => ["tdfoot", "tdfoot", "tdfoot"], :tr => "tr", :tds => ["tdfoot",  "tdfoot", "tdfoot"],  :fs => ["", "", ""],                   :ps => ["mono", "mono", "mono"]     }, 
                                        
                                        :tcs => ["tcnarrow", "tc", "tcnarrow"]
                                       },
                                        
                      :headmedium   => {:thead => {:ths => ["tdhead", "tdhead", "tdhead"], :tr => "tr", :tds => ["tdhead",  "tdhead", "tdhead"],  :fs => ["medium", "medium", "medium"], :ps => ["mono", "mono", "mono"]     }, 
                                        :tbody => {:ths => ["tdhead", "tdhead", "tdhead"], :tr => "tr", :tds => ["td",      "td"    , "td"],      :fs => ["medium", "medium", "medium"], :ps => ["", "", ""]     }, 
                                        :tfoot => {:ths => ["tdfoot", "tdfoot", "tdfoot"], :tr => "tr", :tds => ["td",      "td",     "td"],      :fs => ["medium", "medium", "medium"], :ps => ["", "", ""]     }, 
                                        
                                        :tcs => ["tcnarrow", "tc", "tcnarrow"]
                                       },
                                       
                      :listmedium   => {:thead => {:ths => ["tdhead", "tdhead", "tdhead"], :tr => "tr", :tds => ["tdhead",  "tdhead", "tdhead"],  :fs => ["medium", "medium", "medium"], :ps => ["mono", "mono", "mono"]     }, 
                                        :tbody => {:ths => ["tdhead", "tdhead", "tdhead"], :tr => "tr", :tds => ["td",      "td"    , "td"],      :fs => ["medium", "medium", "medium"], :ps => ["", "", ""]     }, 
                                        :tfoot => {:ths => ["tdfoot", "tdfoot", "tdfoot"], :tr => "tr", :tds => ["tdfoot",  "tdfoot", "tdfoot"],  :fs => ["medium", "medium", "medium"], :ps => ["mono", "mono", "mono"]     }, 
                                        
                                        :tcs => ["tcnarrow", "tc", "tcnarrow"]
                                       },
                                       
                      :boxes        => {:thead => {:ths => ["tdbox", "tdbox", "tdbox"],    :tr => "tr", :tds => ["tdbox", "tdbox", "tdbox"],      :fs => ["", "", ""],                   :ps => ["p", "p", "p"]  }, 
                                        :tbody => {:ths => ["tdbox", "tdbox", "tdbox"],    :tr => "tr", :tds => ["tdbox", "tdbox", "tdbox"],      :fs => ["", "", ""],                   :ps => ["p", "p", "p"]  }, 
                                        :tfoot => {:ths => ["tdbox", "tdbox", "tdbox"],    :tr => "tr", :tds => ["tdbox", "tdbox", "tdbox"],      :fs => ["", "", ""],                   :ps => ["p", "p", "p"]  }, 
                                        
                                        :tcs => ["tc", "tc", "tc"]
                                       },
                                        
                      :invoice      => {:thead => {:ths => ["tdhead", "tdhead", "tdhead"], :tr => "tr", :tds => ["tdhead", "tdhead",  "tdhead" ], :fs => ["medium", "medium", "medium"], :ps => ["mono",    "monoright", "monoright" ] }, 
                                        :tbody => {:ths => ["tdhead", "tdhead", "tdhead"], :tr => "tr", :tds => ["tdbott", "tdbott",  "tdbott" ], :fs => ["medium", "medium", "medium"], :ps => ["justify",     "right",     "right" ] }, 
                                        :tfoot => {:ths => ["tdfoot", "tdfoot", "tdfoot"], :tr => "tr", :tds => ["tdfoot", "tdfoot",  "tdfoot" ], :fs => ["medium", "medium", "medium"], :ps => ["mono",    "monoright", "monoright" ] }, 
                                        
                                        :tcs => ["tcwide", "tcnarrow", "tcnarrow"]
                                       },
                                        
                      :caption      => {:thead => {:ths => ["td", "td", "td"],             :tr => "tr", :tds => ["td", "td", "td"],               :fs => ["", "", ""],                   :ps => ["mono", "mono", "mono"] }, 
                                        :tbody => {:ths => ["td", "td", "td"],             :tr => "tr", :tds => ["td", "td", "td"],               :fs => ["", "", ""],                   :ps => ["mono", "mono", "mono"] }, 
                                        :tfoot => {:ths => ["td", "td", "td"],             :tr => "tr", :tds => ["td", "td", "td"],               :fs => ["", "", ""],                   :ps => ["mono", "mono", "mono"] }, 
                                        
                                        :tcs => ["tc", "tc", "tc"]
                                       }
                      }
                      
      ####################################################################################
      #
      # initialize
      #
      ####################################################################################
      def initialize(text, node, opts={})
        @text                = text
        @paragraphs          = []
        @template_node       = node
        @doc                 = opts[:doc]
        @remove_classes      = opts[:remove_classes]
        @remove_class_prefix = opts[:remove_class_prefix]
        @remove_class_suffix = opts[:remove_class_suffix]
        
        @styles              = opts[:styles]
        
        parse
      end #def
      
      ####################################################################################
      #
      # parse
      #
      ####################################################################################
      def parse
      
        #xml = @template_node.parse("<html>#{@text}</html>")
        xml = "<html>#{@text}</html>"
        odf = parse_formatting(xml).css("html").inner_html
        @paragraphs << odf
        return
      end #def
      
      
      ####################################################################################
      #
      # private
      #
      ####################################################################################
      private
      
      def parse_formatting(tag, level=0)
      
        #
        # strip superfluous control characters
        #
        duptag = tag.dup.to_s.gsub(/\n|\r|\t/, " ")
        
        #
        # strip superfluous whitespace
        #
        duptag.gsub!(/  /, " ") while duptag.match(/  /)
        
        html = Nokogiri::XML( tag.to_s )
        
        #
        # remove unsafe tags
        #
        UNSAFETAGS.each do |ust|
          html.xpath("//*[self::#{ust}]").each do |node|
            node.remove
          end
        end
        
        #
        # divisor - just unpack
        #
        html.xpath("//*[self::div]").reverse.each do |node|
          node.replace( node.dup.children )
        end
        #html.xpath("//*[self::div]").each {|node| node.replace(text_node( "p", node)) }
        
        #
        # remove requested tags with class
        #
        if @remove_classes.present?
          case @remove_classes
          when Array
            contains = @remove_classes.map{|r| "contains(., '#{r}')"}.join(" or ")
          else
            contains = "contains(., '#{@remove_classes}')"
          end
          #nodes = html.xpath(".//*[@class[contains(., '#{contains}')]]")
          nodes = html.xpath(".//*[@class[#{contains}]]")
          nodes.each { |node| node.remove }
        end
        
        #
        # remove requested class prefixes
        #
        if @remove_class_prefix.present?
          case @remove_class_prefix
          when Array
            contains = @remove_class_prefix.map{|r| "contains(., '#{r}')"}.join(" or ")
          else
            contains = "contains(., '#{@remove_class_prefix}')"
          end
          #nodes = html.xpath(".//*[@class[ contains(., '#{@remove_class_prefix}')]]")
          nodes = html.xpath(".//*[@class[#{contains}]]")
          nodes.each do |node| 
            css_classes = node.attr("class").split(" ").select{|c| c.present?}
            case @remove_class_prefix
            when Array
              @remove_class_prefix.each do |rcp|
                css_classes.map!{ |css_class| css_class.gsub!(/\A#{rcp}(.*)\z/) { $1 } }
              end
            else
              css_classes.map!{ |css_class| css_class.gsub!(/\A#{@remove_class_prefix}(.*)\z/) { $1 } }
            end
            node.set_attribute("class", css_classes.join(" "))
          end
        end
        
        #
        # remove requested class suffixes
        #
        if @remove_class_suffix.present?
          case @remove_class_prefix
          when Array
            contains = @remove_class_suffix.map{|r| "contains(., '#{r}')"}.join(" or ")
          else
            contains = "contains(., '#{@remove_class_suffix}')"
          end
          #nodes = html.xpath(".//*[@class[ contains(., '#{@remove_class_suffix}')]]")
          nodes = html.xpath(".//*[@class[#{contains}]]")
          nodes.each do |node| 
            css_classes = node.attr("class").split(" ").select{|c| c.present?}
            case @remove_class_prefix
            when Array
              @remove_class_suffix.each do |rcs|
                css_classes.map!{ |css_class| css_class.gsub!(/\A(.*)#{rcs}\z/) { $1 } }
              end
            else
              css_classes.map!{ |css_class| css_class.gsub!(/\A}(.*)#{@remove_class_suffix}\z/) { $1 } }
            end
            node.set_attribute("class", css_classes.join(" "))
          end
        end
        
        #
        # --- html nestable elements -------------------------------------------------------
        #
        
        #
        # nested list items
        #
        html.xpath("//*[self::li]").each do |node|
          
          li = text_node("list-item")
          
          node.xpath("./text()").each do |text|
            text.replace( blank_node("p", "li", text) ) if text.text.present?
            text.remove unless text.text.present?
          end
          
          node.children.each do |child|
            child = child.replace( text_node("p", "li") << child.dup ) if INLINE.include?(child.name)
            child = child.replace( text_node("p", "li") << child.dup ) if TEXTINLINE.include?(child.name)
            li << parse_formatting(child, level+1).root
          end
          
          node.replace( li )
        end
        
        #
        # nested unordered lists
        #
        html.xpath("//*[self::ul]").each do |node|
          ul  = text_node("list", "ul", node)
          node.replace( parse_formatting(ul, level+1).root )
        end
        
        #
        # nested unordered lists
        #
        html.xpath("//*[self::ol]").each do |node|
          ol  = text_node("list", "ol", node)
          node.replace( parse_formatting(ol, level+1).root )
        end
        
        #
        # --- html tables -----------------------------------------------------------------
        #
        
        #
        # tables
        #
        html.xpath("//*[self::table]").each do |node|
        
          # unpack tables, which should not be encapsulated in a <p> tag, 
          # but which is often seen
          if ["text:p", "p"].include? node.parent.name
            node = node.parent.replace( node.dup )
          end
          
          #
          # use last matching css class for matching a local style
          #
          cssclasses = node["class"].to_s.split(/\ /)
          cssc       = (cssclasses & TABLECLASSES).last&.to_sym || :table
          
          table  = table_node("table",  cssc.to_s, node)
          table["table:template-name"]= cssc.to_s.camelcase
          #new_table = node.replace( parse_formatting(table, level+1).root )
          new_table = node.replace( table )
          
          max_cols = node.
            xpath(".//*[local-name()='tr']").
              map{|tr| tr.xpath("*[local-name()='td']")}.
                map{|a| a.length}.max
                
          max_cols.to_i.times do |col_index|
          
            if col_index == 0 # last
              tccss = TABLESTYLES.dig(cssc, :tcs ).to_a[2] 
              
            elsif col_index == (max_cols - 1) # first 
              tccss = TABLESTYLES.dig(cssc, :tcs ).to_a[0] 
              
            else
              tccss = TABLESTYLES.dig(cssc, :tcs ).to_a[1] 
            end
            
            tc = table_node("table-column", tccss)
            new_table.children.first&.before( tc ) # inserted in reverse order
          end
          
          #---------------------------------------------------------------------------------
          # table row groups thead, tbody, tfoot
          #
          
          # if plain table without rowgroups, then add rowgroup
          rowgroups_count = 0
          %i(thead tbody tfoot).each do |rowgroup|
            rowgroups_count += new_table.xpath(".//*[self::#{rowgroup}]").length
          end
          if rowgroups_count == 0
             tbody = Nokogiri::XML::Node.new("tbody", @doc)
             tbody << new_table.xpath(".//*[self::tr]")
             new_table.xpath(".//*[self::tr]").unlink
             new_table << tbody
          end
          
          # handle all rowgroups
          %i(thead tbody tfoot).each do |rowgroup|
            
            #
            # traverse thead, tbody and tfoot
            #
            new_table.xpath(".//*[self::#{rowgroup}]").each do |row_group_node|
              case rowgroup
              when :thead
                trg  = table_node("table-header-rows", "#{rowgroup}", row_group_node)
              else
                trg  = table_node("table-rows",        "#{rowgroup}", row_group_node)
              end
              #new_row_group_node = row_group_node.replace( parse_formatting(trg, level+1).root )
              new_row_group_node = row_group_node.replace( trg )
              
              #-----------------------------------------------------------------------------
              # table rows
              #
              new_row_group_node.xpath(".//*[self::tr]").each_with_index do |tr_node, tr_index|
                
                trcss = TABLESTYLES.dig(cssc, rowgroup, :tr )
                
                tr  = table_node("table-row", trcss, tr_node)
                #new_tr_node = tr_node.replace( parse_formatting(tr).root )
                new_tr_node = tr_node.replace( tr )
                
                #---------------------------------------------------------------------------
                # table body cells
                #
                new_tr_node.xpath(".//*[self::th or self::td]").each_with_index do |td_node, td_index|
                  
                  if td_index == 0 #first column
                    tdcss = TABLESTYLES.dig(cssc, rowgroup, "#{td_node.name}s".to_sym ).to_a[0]
                    pcss  = TABLESTYLES.dig(cssc, rowgroup, :ps  ).to_a[0]
                    fcss  = TABLESTYLES.dig(cssc, rowgroup, :fs  ).to_a[0]
                  elsif td_index == (max_cols - 1) #last column
                    tdcss = TABLESTYLES.dig(cssc, rowgroup, "#{td_node.name}s".to_sym ).to_a[2]
                    pcss  = TABLESTYLES.dig(cssc, rowgroup, :ps  ).to_a[2]
                    fcss  = TABLESTYLES.dig(cssc, rowgroup, :fs  ).to_a[2]
                  else
                    tdcss = TABLESTYLES.dig(cssc, rowgroup, "#{td_node.name}s".to_sym ).to_a[1]
                    pcss  = TABLESTYLES.dig(cssc, rowgroup, :ps  ).to_a[1]
                    fcss  = TABLESTYLES.dig(cssc, rowgroup, :fs  ).to_a[1]
                  end
                  
                  td = table_node("table-cell", tdcss)
                  
                  # replace all free text in table cell by a p node
                  td_node.xpath("./text()").each do |text|
                    tx = blank_node( "span", fcss, text)
                    text.replace( text_node("p", pcss ) << tx ) if     text.text.present?
                    text.remove                                 unless text.text.present?
                  end
                  
                  # encapsulate all free text in table children in spans
                  td_node.children.each do |child|
                  child.xpath("./text()").each do |text|
                    tx = blank_node( "span", fcss, text)
                    text.replace( tx ) if     text.text.present? #&& child.name != "span"
                    text.remove        unless text.text.present? #&& child.name != "span"
                  end
                  end
                  
                  # replace all inline text in table cell
                  td_node.children.each do |child|
                    if (INLINE + TEXTINLINE).include?( child.name )
                      tx = blank_node( "span", fcss ) << child.dup
                      child = child.replace( text_node("p", pcss) << tx.dup ) 
                    end
                    td << parse_formatting(child).root
                  end
                  
                  td["table:number-columns-spanned"]= td_node['colspan'] if td_node['colspan'].present?
                  td["table:number-rows-spanned"]   = td_node['rowspan'] if td_node['rowspan'].present?
                  
                  new_td_node = td_node.replace( td )
                  
                end
              end
            end
          end
        end
        
        #
        # --- html elements and entities --------------------------------------------------
        #
        
        #
        # newline
        #
        html.xpath("//*[self::br]").each {|node| node.replace(blank_node( "line-break")) }
        
        #
        # horizontal ruler
        #
        html.xpath("//*[self::hr]").each {|node| node.replace(blank_node( "p")) }
        
        
        #
        # --- html block elements ---------------------------------------------------------
        #
        
        #
        # headings
        #
        html.xpath("//*[self::h1]").each  {|node| node.replace(text_node( "p", node)) }
        html.xpath("//*[self::h2]").each  {|node| node.replace(text_node( "p", node)) }
        html.xpath("//*[self::h3]").each  {|node| node.replace(text_node( "p", node)) }
        html.xpath("//*[self::h4]").each  {|node| node.replace(text_node( "p", node)) }
        html.xpath("//*[self::h5]").each  {|node| node.replace(text_node( "p", node)) }
        html.xpath("//*[self::h6]").each  {|node| node.replace(text_node( "p", node)) }
        
        #
        # paragraph
        #
        html.xpath("//*[self::p]").each   {|node| node.replace(text_node( "p", node)) }
        
        #
        # pre
        #
        html.xpath("//*[self::pre]").each {|node| node.replace(text_node( "p", node)) }
        
        #
        # --- html inline elements ---------------------------------------------------------
        #
        
        #
        # bold
        #
        html.xpath("//*[self::strong or self::b]").each   {|node| node.replace(text_node( "span", "bold", node)) }
        
        #
        # italic
        #
        html.xpath("//*[self::em or self::i]").each       {|node| node.replace(text_node( "span", "italic", node)) }
        
        #
        # underline
        #
        html.xpath("//*[self::ins or self::u]").each      {|node| node.replace(text_node( "span", "underline", node)) }
        
        #
        # strikethrough
        #
        html.xpath("//*[self::del or self::strike]").each {|node| node.replace(text_node( "span", "strikethrough", node)) }
        
        #
        # superscript and subscript
        #
        html.xpath("//*[self::sup]").each                 {|node| node.replace(text_node( "span", "sup", node)) }
        html.xpath("//*[self::sub]").each                 {|node| node.replace(text_node( "span", "sub", node)) }
        
        #
        # code
        #
        html.xpath("//*[self::code]").each                {|node| node.replace(text_node( "span", "code", node)) }
        
        #
        # hyperlink or anchor or anchor with content
        #
        html.xpath("//*[self::a]").each do |node|
          
          #
          # self closing a-tag: bookmark
          #
          if node['href'].present?
            cont = text_node("span", "a", node)
           #a = office_node("a") << cont
            a = text_node("a") << cont
            a["xlink:href"]= node['href']
            a["office:target-frame-name"]="_top"
            a["xlink:show"]="replace"
          else
            a = text_node("bookmark")
            a["text:name"]=node['name']
          end
          node.replace(a)
        end
        
        html
      end #def
      
      
      def blank_node( name, node_or_style=nil, node=nil )
        p  = text_node( name, node_or_style ) 
        p.content = node.text if node
        p
      end #def
      
      def office_node( name, node_or_style=nil, node=nil )
      
        p  = Nokogiri::XML::Node.new("office:#{name}", @doc)
        
        if node_or_style.nil?
          #nothing
        elsif node_or_style.blank?
          p << node.dup.children if node
        elsif node_or_style.is_a?(String)
          p['text:style-name']=node_or_style 
          p << node.dup.children if node
        else
          p['text:style-name']=check_style( node_or_style )
          p << node_or_style.dup.children
        end
        p
        
      end #def
      
      def text_node( name, node_or_style=nil, node=nil )
      
        p  = Nokogiri::XML::Node.new("text:#{name}", @doc)
        
        if node_or_style.nil?
          #nothing
        elsif node_or_style.blank?
          p << node.dup.children if node
        elsif node_or_style.is_a?(String)
          p['text:style-name']=node_or_style 
          p << node.dup.children if node
        else
          p['text:style-name']=check_style( node_or_style )
          p << node_or_style.dup.children
        end
        p
      end #def
          
      def table_node( name, node_or_style=nil, node=nil )
      
        p  = Nokogiri::XML::Node.new("table:#{name}", @doc)
        
        if node_or_style.nil?
          #nothing
        elsif node_or_style.blank?
          p << node.dup.children if node
        elsif node_or_style.is_a?(String)
          p['table:style-name']=node_or_style 
          p << node.dup.children if node
        else
          p['table:style-name']=check_style( node_or_style )
          p << node_or_style.dup.children
        end
        p
      end #def
      
      def check_style(node)
      
        style = ""
        
        #
        # header… or…
        #
        if node.name =~ /h(\d)/i
          style = node.name.downcase
          
        #
        # …quote… or…
        #
        elsif node.name == "p" && node.parent && node.parent.name == "blockquote"
          style = "quote"
          
        #
        # …pre
        #
        elsif node.name == "pre"
          style = "pre"
          
        #
        # paragraph
        #
        elsif node.name == "p"
          style = "paragraph"
          
        end
        
        #
        #  class overrides header / quote
        #
        if node["class"].present?
        
          style = node["class"]
          style = remove_prefixes(  @remove_class_prefix, style ) if @remove_class_prefix.present?
          style = remove_suffixes(  @remove_class_suffix, style ) if @remove_class_suffix.present?
        end
        
        #
        #  style overrides class
        #
        case node["style"]
          when /text-align:(\s*)center/
            style = "center"
          when /text-align:(\s*)left/
            style = "left"
          when /text-align:(\s*)right/
            style = "right"
          when /text-align:(\s*)justify/
            style = "justify"
        end
        
        style ||= node.name 
        
        style
      end #def
      
      def remove_prefixes( prefix_array, classes_string)
        css_classes = classes_string.split(/\s+/)
        regex_raw = prefix_array.map{ |p| "\\A#{p}(.*?)\\z" }.join("|")
        css_classes.map{ |css_class| (v = css_class.match(/#{regex_raw}/) { $1.to_s + $2.to_s + $3.to_s }; v.present? ? v : css_class) }.join(" ")
      end #def
      
      def remove_suffixes( prefix_array, classes_string)
        css_classes = classes_string.split(/\s+/)
        regex_raw = prefix_array.map{ |p| "\\A(.*?)#{p}\\z" }.join("|")
        css_classes.map{ |css_class| (v = css_class.match(/#{regex_raw}/) { $1.to_s + $2.to_s + $3.to_s }; v.present? ? v : css_class) }.join(" ")
      end #def
      
    end #class
  end #module
end #module
