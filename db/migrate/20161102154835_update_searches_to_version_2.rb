class UpdateSearchesToVersion2 < ActiveRecord::Migration[5.2]
  def up
    replace_view :searches, version: 2
  end

  def down
    replace_view :searches, version: 1
  end
end
