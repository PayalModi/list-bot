class ChangeUseridToString < ActiveRecord::Migration[5.0]
  def change
  	change_column(:list_items, :userid, :string)
  end
end
