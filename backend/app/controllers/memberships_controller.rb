# frozen_string_literal: true

class MembershipsController < ApplicationController
  skip_before_action :authenticate_user!, only: :accept
  skip_before_action :validate_access_to_wedding!, only: :accept
  before_action -> { doorkeeper_authorize! 'users' }, if: :oauth?
  before_action -> { doorkeeper_authorize! 'users:write' }, if: :oauth?, only: %i[create destroy]

  def index
    json = ActsAsTenant.current_tenant.memberships
                       .order(created_at: :asc)
                       .includes(:user)
                       .as_json(only: %i[id user_id], methods: %i[status user_email])

    # Instruct the frontend which memberships can be removed by the current user
    json.each { it['deletable'] = it.delete('user_id') != current_user.id }
    render json:, status: :ok
  end

  def create
    if (use_case = CreateMembershipUseCase.new(email: user_params[:email])).call
      render json: {}, status: :created
    else
      render json: {
        message: 'Cannot add user',
        errors: use_case.errors
      }, status: :bad_request
    end
  end

  def destroy
    # TODO: Send an email informing that a certain user has removed you from the team.
    membership = Membership.find(params[:id])

    if membership.user_id == current_user.id
      render json: {
        message: 'Team member deletion failed',
        errors: ['Cannot remove yourself from the wedding team.']
      }, status: :forbidden
    else
      membership.destroy!
      render json: {}, status: :ok
    end
  end

  def accept
    membership = Membership.find_by(confirmation_token: params['confirmation_token'])

    if membership&.confirmation_token_expires_at&.future?
      membership.update!(
        confirmed_at: Time.zone.now,
        confirmation_token: nil,
        confirmation_token_expires_at: nil
      )

      redirect_to "/#{ActsAsTenant.current_tenant.slug}"
    else
      redirect_to '/system/unsuccessful-membership-confirmation'
    end
  end

  private

  def user_params
    params.require(:user).permit(:email)
  end
end
