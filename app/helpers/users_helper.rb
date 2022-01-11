# frozen_string_literal: true

module UsersHelper
  include URITemplateHelper

  def accept_terms_param
    (params[:accept_terms] || params[permit_param_key].try(:[], :accept_terms)).to_s == 'true'
  end

  def r_param
    redirect_url = (params[:user]&.permit(:redirect_url) || params.permit(:redirect_url)).try(:[], :redirect_url)
    redirect_url if argu_iri_or_relative?(redirect_url)
  end
end
