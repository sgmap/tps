class SeekAndDestroyExpiredDossiersService
  def self.action_dossier_brouillon
    Dossier.send_brouillon_expiration_notices
    Dossier.destroy_brouillons_and_notify
  end

  def self.action_dossier_en_constuction
  end
end
