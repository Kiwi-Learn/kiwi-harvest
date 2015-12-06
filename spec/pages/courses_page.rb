require 'page-object'

class CoursePage
  include PageObject

  page_url "http://localhost:9292/courses"

  link(:home_link, text: 'Home')
  link(:kiwi_learn_link, text: 'Kiwi Learn')
  link(:search_link, text: 'Search')
  link(:courses_link, text: 'Courses')
  table(:results_table, class: 'table')

  def number_of_courses_shown
    results_table_element.rows-1
  end

end
