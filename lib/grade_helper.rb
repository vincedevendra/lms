module GradeHelper
  GRADE_RANGES = {(92.5..200)  => 'A',  (89.5..92.4) => 'A-',
                  (86.5..89.4) => 'B+', (82.5..86.4) => 'B',
                  (79.5..82.4) => 'B-', (76.5..79.4) => 'C+',
                  (72.5..76.4) => 'C',  (69.5..72.4) => 'C-',
                  (66.5..69.4) => 'D',  (59.5..66.4) => 'D-',
                  (0..59.4)    => 'F'}

  def self.letter_grade(number)
    return unless number.class == Float || number.class == Fixnum
    GRADE_RANGES.find{ |range, __| range === number }.try(:last)
  end

  def self.display_percentage(float)
    float.nil? ? float : "#{float.round(1)}%"
  end

  def self.calculate_median(array)
    length = array.length

    if array.length.odd?
      array[(length / 2)]
    else
      (array[(length / 2) - 1] + array[(length / 2)]) / 2.0
    end
  end
end
