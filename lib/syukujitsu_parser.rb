class SyukujitsuParser
  CSV_PATH = File.expand_path('../../resource/syukujitsu.csv', __FILE__)

  def self.parse(csv_path = CSV_PATH)
    self.new.parse(csv_path)
  end

  def parse(csv_path)
    IO.readlines(csv_path, chomp: true, encoding: 'Shift_JIS:UTF-8')
          .join(',')
          .scan(%r!([^,]+),([0-9]{4})/([0-9]{1,2})/([0-9]{1,2})!)
          .group_by{|_, year| year.to_i}
          .map { |year, holiday_arr|
            holiday_hash = holiday_arr.map {|holiday, *date|
              [Date.new(*date.map(&:to_i)), holiday]
            }.to_h
            [year, holiday_hash]
          }.to_h
  end
end
