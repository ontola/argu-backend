class MembershipsController < ApplicationController
  responds_to :js

  def create
    user = User.find params[:id]
    organisation = Organisation.find params[:organisation_id]
    @membership = Membership.new user: user, organisation: organisation, role: permit_params[:role]
    authorize @membership, :create?

    if @membership.save
      render
    else
      render notifications: [{type: :error, message: 'Fout tijdens het aanmaken'}]
    end
  end

  def update
    @membership = Organisation.find params[:id]
    authorize @membership, :update?

    if @membership.update permit_params
      render 'settings'
    else
      render notifications: [{type: 'error', message: 'Fout tijdens het opslaan'}]
    end
  end

  def destroy
  end

private
  def permit_params
    params.require(:organisation).permit :role
  end
end
