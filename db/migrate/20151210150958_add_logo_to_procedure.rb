class AddLogoToProcedure < ActiveRecord::Migration[5.2]
  def change
    add_column :procedures, :logo, :string
  end
end
