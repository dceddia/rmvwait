require 'test_helper'

class DateTest < ActionView::TestCase
  test "from_param method returns a Date" do
    params = { :name => "Boston",
               :start_date => {
                  :year => 2011,
                  :month => 10,
                  :day => 5 },
               :end_date => {
                  :year => 2011,
                  :month => 11,
                  :day => 1},
               :other_irrelevant_junk => "my face" }

    assert_equal Date.from_param(params[:start_date]), Date.civil(2011, 10, 5)
    assert_equal Date.from_param(params[:end_date]), Date.civil(2011, 11, 1)
  end
end
