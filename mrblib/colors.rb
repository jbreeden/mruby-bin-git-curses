module GitCurses
module Colors
  def self.init
    DEFAULT = CUI::Colors.pair(:WHITE, :BLACK)
    DEFAULT_ALT = CUI::Colors.pair(:BLACK, :WHITE)
    SHA = CUI::Colors.pair(:RED, :BLACK)
    AUTHOR = CUI::Colors.pair(:YELLOW, :BLACK)
    TIME = DEFAULT
    LINE_NO = CUI::Colors.pair(:GREEN, :BLACK)
    SELECTED_LINE = CUI::Colors.pair(:BLACK, :GREEN)
  end
end
end
