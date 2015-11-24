class AssignmentDecorator < Draper::Decorator
  delegate_all

  def display_title_with_point_value
    "#{object.title.titleize} (#{object.point_value})"
  end

  def display_average_grade
    object.average_grade.round(1)
  end

  def display_due_date
    object.due_date.strftime('%b %d, %Y')
  end
end
