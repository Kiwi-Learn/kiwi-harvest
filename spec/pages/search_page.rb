require 'page-object'

class SearchPage
  include PageObject

  page_url "http://localhost:9292/search"

  text_field(:keyword, name: 'keyword')
  button(:check_button, id: 'check-submit')
  table(:results_table, class: 'table')
  h2(:search_header)

  def click_check_button
    check_button
  end

  def search_course(keyword)
    self.keyword = keyword
    click_check_button
  end

  def number_of_courses_shown
    results_table_element.rows-1
  end

end
