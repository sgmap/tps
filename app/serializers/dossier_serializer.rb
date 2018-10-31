class DossierSerializer < ActiveModel::Serializer
  include DossierHelper

  attributes :id,
    :created_at,
    :updated_at,
    :archived,
    :email,
    :state,
    :simplified_state,
    :initiated_at,
    :received_at,
    :processed_at,
    :motivation,
    :instructeurs

  has_one :individual
  has_one :entreprise
  has_one :etablissement
  has_many :cerfa
  has_many :commentaires
  has_many :champs_private
  has_many :pieces_justificatives
  has_many :types_de_piece_justificative

  has_many :champs

  def champs
    champs = object.champs.to_a

    if object.use_legacy_carto?
      champs += object.quartier_prioritaires
      champs += object.cadastres

      if object.user_geometry.present?
        champs << object.user_geometry
      end
    end

    champs
  end

  def cerfa
    []
  end

  def email
    object.user&.email
  end

  def entreprise
    object.etablissement&.entreprise
  end

  def state
    dossier_legacy_state(object)
  end

  def simplified_state
    dossier_display_state(object)
  end

  def initiated_at
    object.en_construction_at&.in_time_zone('UTC')
  end

  def received_at
    object.en_instruction_at&.in_time_zone('UTC')
  end

  def instructeurs
    object.followers_gestionnaires.pluck(:email)
  end

  def created_at
    object.created_at&.in_time_zone('UTC')
  end

  def updated_at
    object.updated_at&.in_time_zone('UTC')
  end

  def processed_at
    object.processed_at&.in_time_zone('UTC')
  end
end
