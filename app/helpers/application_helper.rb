module ApplicationHelper

  def merge_query_parameter(uri, params)
    uri =  URI.parse(uri)
    if params.class != Hash
      params = params.present? ? Hash[*params.split('=')] : Hash.new
    end

    new_query_ar = URI.decode_www_form(uri.query || '') << params.flatten
    uri.query = URI.encode_www_form(new_query_ar)
    uri.to_s
  end

  def resource
    @resource
  end

  def process_cover_photo(object, _params)
    if params[object.class.name.downcase][:cover_photo].present?
      object.assign_attributes(_params.except(:cover_photo))
      if object.valid?
        object.remove_cover_photo!
        return object.save.to_s
      end
    end
    false
  end

end