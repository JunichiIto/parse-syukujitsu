require 'csv'
require 'date'
require 'open-uri'
require 'tempfile'

class SyukujitsuParser
  YEAR_COL = 0
  DATA_COL_RANGE = 2..-1
  ROW_CYCLE = 2
  CSV_PATH = File.expand_path('../../resource/syukujitsu.csv', __FILE__)
  CSV_URL = 'http://www8.cao.go.jp/chosei/shukujitsu/syukujitsu.csv'

  def self.parse_from_web(csv_url = CSV_URL)
    Tempfile.create do |file|
      csv = open(csv_url).read
      File.write(file, csv)
      parse(file.path)
    end
  end

  def self.parse(csv_path = CSV_PATH)
    self.new.parse(csv_path)
  end

  def parse(csv_path)
    pair_rows = generate_pair_rows(csv_path)
    pair_rows.map { |pair_cols|
      year = parse_year(pair_cols[YEAR_COL].first)
      [year, to_data(pair_cols)]
    }.to_h
  end

  private

  def generate_pair_rows(csv_path)
    CSV.read(csv_path, external_encoding: 'CP932', internal_encoding: 'UTF-8')
        .transpose
        .each_slice(ROW_CYCLE)
        .map(&:transpose)
  end

  def to_data(pair_cols)
    pair_cols[DATA_COL_RANGE].map { |name, date|
      parsed_date = try_date_parse(date)
      [parsed_date, name] if parsed_date
    }.compact.to_h
  end

  def try_date_parse(text)
    Date.parse(text) rescue nil
  end

  def parse_year(text)
    text[/\d{4}/].to_i
  end
end