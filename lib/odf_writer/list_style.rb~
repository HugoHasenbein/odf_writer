module ODFWriter

  ########################################################################################
  #
  # ListStyle: add style for ul, ol up to  6 levels deep
  #
  ########################################################################################
  class ListStyle
  
    ######################################################################################
    #
    # initialize
    #
    ######################################################################################
    def initialize( list_style )
      @list_style = list_style
      @font  = {}
    end #def
    
    ######################################################################################
    #
    # add_list_style
    #
    ######################################################################################
    def add_list_style( xml )
    
      ns                                   = xml.collect_namespaces
      automatic_styles                     = xml.at("//office:automatic-styles", ns)
      automatic_styles                     << create_list( xml ) if automatic_styles.present?
      
      if @font.present?
        font_declarations                  = xml.at("//office:font-face-decls", ns)
        font_declarations                  << create_font( xml ) if font_declarations.present?
      end
      
    end #def
    
    ######################################################################################
    #
    # private
    #
    ######################################################################################
    private
    
    def create_font( xml )
      node                               = Nokogiri::XML::Node.new('style:font-face', xml)
      node["style:name"]                 = @font[:font_name]
      node["svg:font-family"]            = @font[:font_family]
      node["style:font-family-generic"]  = @font[:font_family_generic]
      node["style:font-pitch"]           = @font[:font_pitch]
      node
    end #def
    
    def create_list( xml )
        
      list_style                                                = Nokogiri::XML::Node.new('text:list-style', xml)
      
      #
      # common properties
      #
      case @list_style
      
        when :ul
          list_style['style:name']                              = "ul"
          
          #
          # Level 1
          #
          list_bullet                                           = Nokogiri::XML::Node.new('text:list-level-style-bullet', xml) 
          list_bullet['text:level']                             = "1"
          list_bullet['text:bullet-char']                       = "•"
          list_style << list_bullet
          
          list_level                                            = Nokogiri::XML::Node.new('style:list-level-properties', xml)
          list_level['text:list-level-position-and-space-mode'] = "label-alignment"
          list_bullet << list_level
          
          list_label                                            = Nokogiri::XML::Node.new('style:list-level-label-alignment', xml) 
          list_label['text:label-followed-by']                  = "listtab"
          list_label['text:list-tab-stop-position']             = "1cm"
          list_label['fo:text-indent']                          = "-0.5cm"
          list_label['fo:margin-left']                          = "1cm"
          list_level << list_label
          
          #
          # Level 2
          #
          list_bullet                                           = Nokogiri::XML::Node.new('text:list-level-style-bullet', xml) 
          list_bullet['text:level']                             = "2"
          list_bullet['text:bullet-char']                       = "◦"
          list_style << list_bullet
          
          list_level                                            = Nokogiri::XML::Node.new('style:list-level-properties', xml)
          list_level['text:list-level-position-and-space-mode'] = "label-alignment"
          list_bullet << list_level
          
          list_label                                            = Nokogiri::XML::Node.new('style:list-level-label-alignment', xml) 
          list_label['text:label-followed-by']                  = "listtab"
          list_label['text:list-tab-stop-position']             = "1.5cm"
          list_label['fo:text-indent']                          = "-0.5cm"
          list_label['fo:margin-left']                          = "1.5cm"
          list_level << list_label
          
          #
          # Level 3
          #
          list_bullet                                           = Nokogiri::XML::Node.new('text:list-level-style-bullet', xml) 
          list_bullet['text:level']                             = "3"
          list_bullet['text:bullet-char']                       = "▪"
          list_style << list_bullet
          
          list_level                                            = Nokogiri::XML::Node.new('style:list-level-properties', xml)
          list_level['text:list-level-position-and-space-mode'] = "label-alignment"
          list_bullet << list_level
          
          list_label                                            = Nokogiri::XML::Node.new('style:list-level-label-alignment', xml) 
          list_label['text:label-followed-by']                  = "listtab"
          list_label['text:list-tab-stop-position']             = "2cm"
          list_label['fo:text-indent']                          = "-0.5cm"
          list_label['fo:margin-left']                          = "2cm"
          list_level << list_label
          
          #
          # Level 4
          #
          list_bullet                                           = Nokogiri::XML::Node.new('text:list-level-style-bullet', xml) 
          list_bullet['text:level']                             = "4"
          list_bullet['text:bullet-char']                       = "•"
          list_style << list_bullet
          
          list_level                                            = Nokogiri::XML::Node.new('style:list-level-properties', xml)
          list_level['text:list-level-position-and-space-mode'] = "label-alignment"
          list_bullet << list_level
          
          list_label                                            = Nokogiri::XML::Node.new('style:list-level-label-alignment', xml) 
          list_label['text:label-followed-by']                  = "listtab"
          list_label['text:list-tab-stop-position']             = "2.5cm"
          list_label['fo:text-indent']                          = "-0.5cm"
          list_label['fo:margin-left']                          = "2.5cm"
          list_level << list_label
          
          #
          # Level 5
          #
          list_bullet                                           = Nokogiri::XML::Node.new('text:list-level-style-bullet', xml) 
          list_bullet['text:level']                             = "5"
          list_bullet['text:bullet-char']                       = "◦"
          list_style << list_bullet
          
          list_level                                            = Nokogiri::XML::Node.new('style:list-level-properties', xml)
          list_level['text:list-level-position-and-space-mode'] = "label-alignment"
          list_bullet << list_level
          
          list_label                                            = Nokogiri::XML::Node.new('style:list-level-label-alignment', xml) 
          list_label['text:label-followed-by']                  = "listtab"
          list_label['text:list-tab-stop-position']             = "3cm"
          list_label['fo:text-indent']                          = "-0.5cm"
          list_label['fo:margin-left']                          = "3cm"
          list_level << list_label
          
          #
          # Level 6
          #
          list_bullet                                           = Nokogiri::XML::Node.new('text:list-level-style-bullet', xml) 
          list_bullet['text:level']                             = "6"
          list_bullet['text:bullet-char']                       = "▪"
          list_style << list_bullet
          
          list_level                                            = Nokogiri::XML::Node.new('style:list-level-properties', xml)
          list_level['text:list-level-position-and-space-mode'] = "label-alignment"
          list_bullet << list_level
          
          list_label                                            = Nokogiri::XML::Node.new('style:list-level-label-alignment', xml) 
          list_label['text:label-followed-by']                  = "listtab"
          list_label['text:list-tab-stop-position']             = "3.5cm"
          list_label['fo:text-indent']                          = "-0.5cm"
          list_label['fo:margin-left']                          = "3.5cm"
          list_level << list_label
          
        when :ol
          list_style['style:name']                              = "ol"
          
          #
          # Level 1
          #
          list_number                                           = Nokogiri::XML::Node.new('text:list-level-style-number', xml) 
          list_number['text:level']                             = "1"
          list_number['style:num-suffix']                       = "."
          list_number['style:num-format']                       = "1"
          list_style << list_number
          
          list_level                                            = Nokogiri::XML::Node.new('style:list-level-properties', xml)
          list_level['text:list-level-position-and-space-mode'] = "label-alignment"
          list_number << list_level
          
          list_label                                            = Nokogiri::XML::Node.new('style:list-level-label-alignment', xml) 
          list_label['text:label-followed-by']                  = "listtab"
          list_label['text:list-tab-stop-position']             = "1cm"
          list_label['fo:text-indent']                          = "-0.5cm"
          list_label['fo:margin-left']                          = "1cm"
          list_level << list_label
          
          #
          # Level 2
          #
          list_number                                           = Nokogiri::XML::Node.new('text:list-level-style-number', xml) 
          list_number['text:level']                             = "2"
          list_number['style:num-suffix']                        = "."
          list_number['style:num-format']                        = "1"
          list_style << list_number
          
          list_level                                            = Nokogiri::XML::Node.new('style:list-level-properties', xml)
          list_level['text:list-level-position-and-space-mode'] = "label-alignment"
          list_number << list_level
          
          list_label                                            = Nokogiri::XML::Node.new('style:list-level-label-alignment', xml) 
          list_label['text:label-followed-by']                  = "listtab"
          list_label['text:list-tab-stop-position']             = "1.5cm"
          list_label['fo:text-indent']                          = "-0.5cm"
          list_label['fo:margin-left']                          = "1.5cm"
          list_level << list_label
          
          #
          # Level 3
          #
          list_number                                           = Nokogiri::XML::Node.new('text:list-level-style-number', xml) 
          list_number['text:level']                             = "3"
          list_number['style:num-suffix']                       = "."
          list_number['style:num-format']                       = "1"
          list_style << list_number
          
          list_level                                            = Nokogiri::XML::Node.new('style:list-level-properties', xml)
          list_level['text:list-level-position-and-space-mode'] = "label-alignment"
          list_number << list_level
          
          list_label                                            = Nokogiri::XML::Node.new('style:list-level-label-alignment', xml) 
          list_label['text:label-followed-by']                  = "listtab"
          list_label['text:list-tab-stop-position']             = "2cm"
          list_label['fo:text-indent']                          = "-0.5cm"
          list_label['fo:margin-left']                          = "2cm"
          list_level << list_label
          
          #
          # Level 4
          #
          list_number                                           = Nokogiri::XML::Node.new('text:list-level-style-number', xml) 
          list_number['text:level']                             = "4"
          list_number['style:num-suffix']                       = "."
          list_number['style:num-format']                       = "1"
          list_style << list_number
          
          list_level                                            = Nokogiri::XML::Node.new('style:list-level-properties', xml)
          list_level['text:list-level-position-and-space-mode'] = "label-alignment"
          list_number << list_level
          
          list_label                                            = Nokogiri::XML::Node.new('style:list-level-label-alignment', xml) 
          list_label['text:label-followed-by']                  = "listtab"
          list_label['text:list-tab-stop-position']             = "2.5cm"
          list_label['fo:text-indent']                          = "-0.5cm"
          list_label['fo:margin-left']                          = "2.5cm"
          list_level << list_label
          
          #
          # Level 5
          #
          list_number                                           = Nokogiri::XML::Node.new('text:list-level-style-number', xml) 
          list_number['text:level']                             = "5"
          list_number['style:num-suffix']                       = "."
          list_number['style:num-format']                       = "1"
          list_style << list_number
          
          list_level                                            = Nokogiri::XML::Node.new('style:list-level-properties', xml)
          list_level['text:list-level-position-and-space-mode'] = "label-alignment"
          list_number << list_level
          
          list_label                                            = Nokogiri::XML::Node.new('style:list-level-label-alignment', xml) 
          list_label['text:label-followed-by']                  = "listtab"
          list_label['text:list-tab-stop-position']             = "3cm"
          list_label['fo:text-indent']                          = "-0.5cm"
          list_label['fo:margin-left']                          = "3cm"
          list_level << list_label
          
          #
          # Level 6
          #
          list_number                                           = Nokogiri::XML::Node.new('text:list-level-style-number', xml) 
          list_number['text:level']                             = "6"
          list_number['style:num-suffix']                       = "."
          list_number['style:num-format']                       = "1"
          list_style << list_number
          
          list_level                                            = Nokogiri::XML::Node.new('style:list-level-properties', xml)
          list_level['text:list-level-position-and-space-mode'] = "label-alignment"
          list_number << list_level
          
          list_label                                            = Nokogiri::XML::Node.new('style:list-level-label-alignment', xml) 
          list_label['text:label-followed-by']                  = "listtab"
          list_label['text:list-tab-stop-position']             = "3.5cm"
          list_label['fo:text-indent']                          = "-0.5cm"
          list_label['fo:margin-left']                          = "3.5cm"
          list_level << list_label
          
      end
      
      list_style
      
    end #def
    
  end #class
end #module