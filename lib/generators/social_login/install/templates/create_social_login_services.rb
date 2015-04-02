class CreateSocialLoginServices < ActiveRecord::Migration
  def change
    create_table :social_login_services do |t|
      t.string :type
      t.json :access_token
      t.string :remote_id
      t.integer :user_id
      t.string :method
      t.timestamps
    end
  end
end
