# frozen_string_literal: true
module Common
  # The most commonly used response handlers per response format
  # Methods are named using their numbered counterpart for brevity
  #   and consistency.
  module Responses
    # Method to determine where the action should redirect to after it fails.
    # @param [Class] resource The resource from the result of the action
    def redirect_model_failure(resource)
      resource
    end

    # Method to determine where the action should redirect to after it succeeds.
    # @param [Class] resource The resource from the result of the action
    def redirect_model_success(resource)
      action_name == 'destroy' ? resource.parent_model : resource
    end

    def respond_with_200(resource, format)
      case format
      when :json, :json_api
        render json: resource
      else
        raise_unkown_format
      end
    end

    def respond_with_201(resource, format)
      case format
      when :json, :json_api
        render json: resource, status: :created, location: resource
      when :js
        head :created
      else
        raise_unkown_format
      end
    end

    def respond_with_204(_, format)
      case format
      when :json, :json_api
        head :no_content
      else
        raise_unkown_format
      end
    end

    def respond_with_304(_, format)
      case format
      when :json_api
        head 304
      else
        raise_unkown_format
      end
    end

    def respond_with_400(resource, format)
      case format
      when :json, :json_api
        render json: resource.errors, status: :bad_request
      when :js
        head 400
      else
        raise_unkown_format
      end
    end

    def respond_with_422(resource, format)
      case format
      when :json
        render json: resource.errors, status: :unprocessable_entity
      when :json_api
        render json_api_error(422, resource.errors)
      else
        raise_unkown_format
      end
    end

    def respond_with_form(resource)
      render :form, locals: {model_name => resource}
    end

    def respond_with_form_js(resource)
      respond_js(
        "#{controller_name}/form",
        resource: resource,
        controller_name.singularize.to_sym => resource
      )
    end

    def respond_js(view, locals)
      render 'container_replace', locals: {view: view, locals: locals}
    end

    # @param resource [ActiveRecord::Base] The resource to redirect to.
    # @param _ [Symbol] The action to render the message for.
    def respond_with_redirect_failure(resource, _)
      redirect_with_message redirect_model_failure(resource),
                            message_failure
    end

    # @param resource [ActiveRecord::Base] The resource to redirect to.
    # @param action [Symbol] The action to render the message for.
    def respond_with_redirect_success(resource, action, opts = {})
      redirect_with_message redirect_model_success(resource),
                            message_success(resource, action),
                            opts
    end

    def respond_with_redirect_success_js(resource, action)
      flash[:notice] = message_success(resource, action)
      url = url_for(redirect_model_success(resource))

      if iframe?
        url = URI.parse(url)
        params = URI.decode_www_form(url.query || '') << ['trigger', Random.rand(10_000)]
        url.query = URI.encode_www_form(params)
      end

      render 'turbolinks_redirect', locals: {location: url}
    end

    private

    def raise_unkown_format
      raise Error('Unknown format')
    end

    def redirect_with_message(location, message, opts = {})
      redirect_to location, opts.merge(notice: message.capitalize)
    end

    def message_failure
      t('errors.general')
    end

    # @param resource [ActiveRecord::Base] The resource to display the type for.
    # @param action [Symbol] The action to render the message for.
    def message_success(resource, action)
      t("type_#{action}_success", type: type_for(resource)).capitalize
    end
  end
end
