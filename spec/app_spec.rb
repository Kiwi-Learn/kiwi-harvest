require_relative 'spec_helper'
require 'json'

describe 'Kiwi harvest Stories' do
  include PageObject::PageFactory
  before do
    unless @browser
      @headless = Headless.new
      @browser = Watir::Browser.new
    end
  end

  describe 'Visiting the home page' do
    it 'finds the title' do
      visit HomePage do |page|
        page.title.must_equal 'Kiwi harvest'
        page.home_link_element.exists?.must_equal true
        page.kiwi_learn_link_element.exists?.must_equal true
        page.search_link_element.exists?.must_equal true
        page.courses_link_element.exists?.must_equal true
      end
    end

    it 'check home page' do
      visit HomePage do |page|
        page.click_home_link
        page.homepage_header.must_equal 'Hello, welcome to Kiwi Harvest!!'

        page.click_kiwi_learn_link
        page.homepage_header.must_equal 'Hello, welcome to Kiwi Harvest!!'
      end
    end

  end

  describe 'Search a course' do
    it 'can search a course' do

      visit SearchPage do |page|
        page.browser.url.must_match %r{http.*/search}
        page.search_header.must_equal 'Search a course with keyword'

        # GIVEN & WEHN
        page.search_course('program')

        # THEN
        page.browser.url.must_match %r{http.*/courses/.*}
        page.number_of_courses_shown.must_equal 1

      end
    end
  end

  describe 'List all courses' do
    it 'check courses list page and table' do
      # GIVEN
      visit CoursePage do |page|
        # WHEN
        # THEN
        page.browser.url.must_match %r{http.*/courses}
        page.number_of_courses_shown.must_be :>=, 200
      end

    end
  end

  after do
    @browser.close
    # @headless.destroy
  end
end
