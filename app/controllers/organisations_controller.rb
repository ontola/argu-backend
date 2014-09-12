class OrganisationsController < ApplicationController
  def show
    @org = Organisation.find params[:id]
    authorize @org, :show?
  end

  def new
    @org = Organisation.new
    authorize @org, :new?
  end

  def create
    @org = Organisation.new permit_params
    authorize @org, :create?

    if @org.save
      redirect_to @org
    else
      render notifications: [{type: :error, message: 'Fout tijdens het aanmaken'}]
    end
  end

  def edit
    @org = Organisation.find params[:id]
    authorize @org, :update?
  end

  def update
  end

  def delete
  end

  def destroy
  end

private
  def permit_params
    params.require(:organisation).permit :name, :description, :slogan, :website, :public, :listed, :requestable, :key_tags
  end
end
