class CourseDecorator < Draper::Decorator
  delegate_all
  decorates_finders

  def schedule
    hash = Date::DAYS_INTO_WEEK.invert
    hash[3] = 'R'

    if object.meeting_days
      days_string = object.meeting_days.map do |day_num| hash[day_num].to_s.first.capitalize
      end.join
    end

    if object.start_time? && object.end_time?
      times_string = "#{object.start_time} - #{object.end_time}"
    end

    if days_string.present? && times_string.present?
      days_string + ' ' + times_string
    elsif days_string.present?
      days_string
    elsif times_string.present?
      times_string
    else
      "No Schedule Given"
    end
  end

  def display_location
    object.location? ? object.location : "No Location Given"
  end

  def display_title
    object.code? ? "#{object.title.titleize} (#{object.code})" : object.title.titleize
  end

  def display_notes
    object.notes? ? object.notes : "No Notes Given"
  end
end
