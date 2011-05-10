module ResultsHelper
  def display_response(r_set, question)
    sets = r_set.responses.select do |r|
      r.question == question && r.question.display_order == question.display_order
    end

    if sets.size == 0
      "-"
    elsif sets.size == 1
      (sets.first.string_value || sets.first.text_value || show_answer(sets.first))
    else
      sets.collect do |set|
        show_answer(set) + "<br/>"
      end.join
    end
  end

  def show_answer(set)
    set.answer.text
  end
end
