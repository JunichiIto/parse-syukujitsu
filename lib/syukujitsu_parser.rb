require 'csv'
require 'date'

class SyukujitsuParser
  YEAR_COL = 0
  DATA_COL_RANGE = 2..-1
  ROW_CYCLE = 2
  CSV_PATH = File.expand_path('../../resource/syukujitsu.csv', __FILE__)

  def self.parse(csv_path = CSV_PATH)
    self.new.parse(csv_path)
  end

  def parse(csv_path)
    pairs = to_transposed_array(csv_path)
                .each_slice(ROW_CYCLE)
                .map { |name_row, date_row| name_row.zip(date_row) }
    pairs.map { |cols|
      year = parse_year(cols[YEAR_COL][0])
      data = cols[DATA_COL_RANGE].map { |name, date|
        if parsed_date = try_date_parse(date)
          [parsed_date, name]
        end
      }.compact.to_h
      [year, data]
    }.to_h
  end

  def to_transposed_array(csv_path)
    raw_grid = []
    CSV.foreach(csv_path, encoding: 'CP932') { |row|
      cols = row.map { |col| col&.encode('UTF-8') }
      raw_grid << cols
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