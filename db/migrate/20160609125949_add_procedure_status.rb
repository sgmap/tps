class AddProcedureStatus < ActiveRecord::Migration[5.2]
  class Procedure < ApplicationRecord
  end

  def change
    add_column :procedures, :published, :boolean, default: false, null: false
    Procedure.all.each do |procedure|
      procedure.published = true
      procedure.save!
    end
  end
end
