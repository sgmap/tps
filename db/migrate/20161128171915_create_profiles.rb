class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.references :user, null: false
      t.string :gender, null: true
      t.string :given_name, null: true
      t.string :family_name, null: true
      t.string :entreprise_siret, null: true
      t.date :birthdate, null: true
      t.string :picture, null: true
      t.string :picture_secure_token, null: true
      t.boolean :certified, null: false, default: false
    end
  end
end
