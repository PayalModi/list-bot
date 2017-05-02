class CreateListItems < ActiveRecord::Migration[5.0]
  def change
    create_table :list_items do |t|
      t.string :itemname
      t.timestamp :created_at
      t.integer :userid

      t.timestamps
    end
  end
end
