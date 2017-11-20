class ChampsService
  class << self
    def save_champs(champs, params)
      fill_champs(champs, params)

      champs.select(&:changed?).each(&:save)
    end

    def build_error_messages(champs)
      champs.select(&:mandatory_and_blank?)
        .map { |c| "Le champ #{c.libelle.truncate(200)} doit être rempli." }
    end

    private

    def fill_champs(champs, h)
      datetimes, not_datetimes = champs.partition { |c| c.type_champ == 'datetime' }

      datetimes.each { |c| c.value = parse_datetime(c.id, h) }

      numbers, other = not_datetimes.partition { |c| c.type_champ == 'number' }

      numbers.each { |c| c.value = parse_float(h[:champs]["'#{c.id}'"]) }

      other.each { |c| c.value = h[:champs]["'#{c.id}'"] }
    end

    def parse_float(value)
      if value.present?
        value.gsub(',', '.').to_f.to_s
      else
        nil
      end
    end

    def parse_datetime(champ_id, h)
      "#{h[:champs]["'#{champ_id}'"]} #{extract_hour(champ_id, h)}:#{extract_minute(champ_id, h)}"
    end

    def extract_hour(champ_id, h)
      h[:time_hour]["'#{champ_id}'"]
    end

    def extract_minute(champ_id, h)
      h[:time_minute]["'#{champ_id}'"]
    end
  end
end
