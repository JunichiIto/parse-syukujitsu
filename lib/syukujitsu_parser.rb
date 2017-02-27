require 'csv'
require 'date'

class SyukujitsuParser
  YEAR_COL = 0
  HEADER_COL = 1
  ROW_CYCLE = 2
  CSV_PATH = File.expand_path('../../resource/syukujitsu.csv', __FILE__)

  def self.parse(csv_path = CSV_PATH)
    self.new.parse(csv_path)
  end

  def parse(csv_path)
    pairs = to_transposed_array(csv_path)
                .each_slice(ROW_CYCLE)
                .map { |name_row, date_row| name_row.zip(date_row) }
    ret = {}
    pairs.each_with_index { |cols, row_no|
      year = parse_year(cols[YEAR_COL][0])
      hash = {}
      ret[year] = hash
      cols.each_with_index { |(name, date), col_no|
        if col_no > HEADER_COL
          if parsed_date = try_date_parse(date)
            hash[parsed_date] = name
          end
        end
      }
    }
    ret
  end

  def to_transposed_array(csv_path)
    raw_grid = []
    CSV.foreach(csv_path, encoding: 'CP932').with_index { |row, row_no|
      cols = []
      raw_grid << cols
      row.each_with_index { |col, col_no|
        val = col&.encode('UTF-8')
        cols << val
      }
    }
    raw_grid.transpose
  end

  def try_date_parse(text)
    Date.parse(text) rescue nil
  end

  def parse_year(text)
    text[/\d{4}/].to_i
  end
end