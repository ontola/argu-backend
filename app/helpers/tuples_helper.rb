module TuplesHelper
  def generate_tuple_in_string(cc)
    "(#{cc.map { |t| "('#{t[0]}', #{t[1]})" }.join(', ')})"
  end

  def match_record_poly_tuples(cc, foreign_name)
    if foreign_name.include? '.'
      "('#{foreign_name}_type', '#{foreign_name}_id') IN #{generate_tuple_in_string(cc)}"
    else
      "(#{foreign_name}_type, #{foreign_name}_id) IN #{generate_tuple_in_string(cc)}"
    end
  end
end
