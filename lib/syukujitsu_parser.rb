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
    pairs = generate_pairs(csv_path)
    pairs.map { |cols|
      year = parse_year(cols[YEAR_COL].first)
      [year, to_data(cols)]
    }.to_h
  end

  private

  def generate_pairs(csv_path)
    read_and_transpose_csv(csv_path)
        .each_slice(ROW_CYCLE)
        .map(&:transpose)
  end

  def to_data(cols)
    cols[DATA_COL_RANGE].map { |name, date|
      if parsed_date = try_date_parse(date)
        [parsed_date, name]
      end
    }.compact.to_h
  end

  def read_and_transpose_csv(csv_path)
    CSV.foreach(csv_path, encoding: 'CP932').map { |row|
      row.map { |col| col&.encode('UTF-8') }
    }.transpose
  end

  def try_date_parse(text)
    Date.parse(text) rescue nil
  end

  def parse_year(text)
    text[/\d{4}/].to_i
  end
end