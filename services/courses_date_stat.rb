require 'virtus'

##
# Value object for results from searching a tutorial set for missing badges
class CoursesDateStatisticsResult
  include Virtus.model

  attribute :code
  attribute :twenty_sixteen
  attribute :twenty_fifteen
  attribute :twenty_fourteen
  attribute :twenty_thirteen
  attribute :twenty_twelve

  def to_json
    to_hash.to_json
  end
end

##
# Service object to get Courses Date Statistics from API
class GetCoursesDateStatisticsAPI
  def initialize(api_url)
    @api_url = api_url

    @num_to_mon_map = {
      1 => 'JAN', 2 => 'FEB', 3 => 'MAR', 4 => 'APR', 5 => 'MAY',
      6 => 'JUN', 7 => 'JUL', 8 => 'AUG', 9 => 'SEP', 10 => 'OCT',
      11 => 'NOV', 12 => 'DEC'
    }

    @date_stat = init_date_stat(2012, 2016)
  end

  def init_date_stat(from_year, to_year)
    date_stat = {}
    for y in from_year..to_year
      date_stat[y] = {
        'JAN' => 0, 'FEB' => 0, 'MAR' => 0, 'APR' => 0, 'MAY' => 0, 'JUN' => 0,
        'JUL' => 0, 'AUG' => 0, 'SEP' => 0, 'OCT' => 0, 'NOV' => 0, 'DEC' => 0
      }
    end
    date_stat
  end

  def call
    date_stat = CoursesDateStatisticsResult.new
    results = HTTParty.get(@api_url)
    date_stat.code = results.code

    courses = JSON.parse(results)

    courses.each do |result|
      years = result['date'].split('-')[0].to_i
      fromMon = result['date'].split('-')[1].to_i
      if years == 2016
        @date_stat[2016][@num_to_mon_map[fromMon]] += 1
      elsif years == 2015
        @date_stat[2015][@num_to_mon_map[fromMon]] += 1
      elsif years == 2014
        @date_stat[2014][@num_to_mon_map[fromMon]] += 1
      elsif years == 2013
        @date_stat[2013][@num_to_mon_map[fromMon]] += 1
      elsif years == 2012
        @date_stat[2012][@num_to_mon_map[fromMon]] += 1
      else
        # Not in 2012 to 2016
      end
    end

    date_stat.twenty_sixteen = @date_stat[2016]
    date_stat.twenty_fifteen = @date_stat[2015]
    date_stat.twenty_fourteen = @date_stat[2014]
    date_stat.twenty_thirteen = @date_stat[2013]
    date_stat.twenty_twelve = @date_stat[2012]

    date_stat
  end
end
