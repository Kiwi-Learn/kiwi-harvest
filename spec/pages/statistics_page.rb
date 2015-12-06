require 'page-object'

class StatisticsPage
  include PageObject

  page_url "http://localhost:9292/statistics"

  div(:chart_2015, id: 'courses-2015')
  div(:chart_2014, id: 'courses-2014')
  div(:chart_2013, id: 'courses-2013')
  div(:chart_2012, id: 'courses-2012')
  h1(:statistics_header)

end
