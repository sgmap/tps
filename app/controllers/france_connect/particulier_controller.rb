class FranceConnect::ParticulierController < ApplicationController
  def login
    if FranceConnectService.enabled?
      redirect_to FranceConnectService.new(credentials).authorization_uri
      # store the consumed procedure path again as it will be reused by the callback action
      store_location_for(:user, procedure_path)
    else
      redirect_to new_user_session_path
    end
  end

  def callback
    return redirect_to new_user_session_path if callback_params[:code].blank?

    fcs = FranceConnectService.new(credentials.merge(code: callback_params[:code]))
    fci = fcs.find_or_retrieve_france_connect_information
    fci.associate_user!

    unless fci.user&.can_france_connect?
      fci.destroy
      redirect_to new_user_session_path, alert: t('errors.messages.france_connect.forbidden_html', reset_link: new_user_password_path)
      return
    end

    connect_france_connect_particulier(fci.user)
  rescue Rack::OAuth2::Client::Error => e
    Rails.logger.error e.message
    redirect_to new_user_session_path, alert: t('errors.messages.france_connect.connexion')
  end

  private

  def callback_params
    params.permit(:code, :state)
  end

  def procedure_path
    @procedure_path ||= stored_location_for(:user)
  end

  def credentials
    @credentials = FranceConnectCredentialsService.new.call(procedure_path)
  end

  def connect_france_connect_particulier(user)
    if user_signed_in?
      sign_out :user
    end

    if instructeur_signed_in?
      sign_out :instructeur
    end

    if administrateur_signed_in?
      sign_out :administrateur
    end

    sign_in user

    user.france_connect_particulier!

    redirect_to(procedure_path || root_path(current_user))
  end
end
