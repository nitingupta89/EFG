class EnablePasswordArchivable < ActiveRecord::Migration
  def up
    create_table :old_passwords do |t|
      t.string :encrypted_password
      t.string :password_salt
      t.string :password_archivable_type, :null => false
      t.integer :password_archivable_id, :null => false
      t.datetime :created_at
    end
    add_index :old_passwords,
        [:password_archivable_type, :password_archivable_id],
        :name => :index_password_archivable
  end

  def down
    drop_table :old_passwords
  end
end
