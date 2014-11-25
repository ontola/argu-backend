module ApplicationHelper

  def merge_query_parameter(uri, params)
    uri =  URI.parse(uri)
    new_query_ar = URI.decode_www_form(uri.query) << params.flatten
    uri.query = URI.encode_www_form(new_query_ar)
    uri.to_s
  end

end