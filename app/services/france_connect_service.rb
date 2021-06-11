class FranceConnectService
  def initialize(code: nil, identifier: nil, secret: nil, **kwargs)
    deps = kwargs.symbolize_keys
    @code = code
    @identifier = identifier
    @secret = secret
    @client_model = deps.fetch(:client_model, FranceConnectParticulierClient)
    @information_repository = deps.fetch(:information_repository, FranceConnectInformation)
    @information_model = deps.fetch(:information_model, FranceConnectInformation)
  end

  def self.enabled?
    Rails.configuration.x.france_connect.enabled
  end

  def authorization_uri
    client.authorization_uri(
      scope: [:profile, :email],
      state: SecureRandom.hex(16),
      nonce: SecureRandom.hex(16),
      acr_values: Rails.configuration.x.fcp.acr_values
    )
  end

  def find_or_retrieve_france_connect_information
    fetched_fci = fetch_france_connect_information!
    fci_identifier = fetched_fci[:france_connect_particulier_id]

    information_repository.find_by(france_connect_particulier_id: fci_identifier) || fetched_fci
  end

  private

  attr_reader :code, :identifier, :secret, :information_repository, :information_model

  def credentials
    return nil if identifier.nil? && secret.nil?

    { identifier: identifier, secret: secret }
  end

  def client
    @client ||= @client_model.new(code, credentials)
  end

  def retrieve_token!
    client.access_token!(
      client_auth_method: :secret,
      grant_type: :authorization_code,
      redirect_uri: Rails.configuration.x.fcp.redirect_uri,
      code: code
    )
  end

  def retrieve_user_information!
    retrieve_token!.userinfo!
  end

  def fetch_france_connect_information!
    raw = retrieve_user_information!.raw_attributes

    information_model.new(
      gender: raw[:gender],
      given_name: raw[:given_name],
      family_name: raw[:family_name],
      email_france_connect: raw[:email],
      birthdate: raw[:birthdate],
      birthplace: raw[:birthplace],
      france_connect_particulier_id: raw[:sub]
    )
  end
end
