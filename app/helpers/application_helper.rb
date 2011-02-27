module ApplicationHelper
  def time_ago_in_words(time)
    result = (time.utc - Time.now.utc > 0) ? "(+) " : "(-) "
    result += super
    result
  end
end
