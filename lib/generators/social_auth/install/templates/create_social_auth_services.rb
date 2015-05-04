class CreateSocialAuthServices < ActiveRecord::Migration
  def change
    create_table :social_auth_services do |t|
      t.string :type, default: "SocialAuth::Service"
      t.json :access_token
      t.string :remote_id
      t.integer :user_id
      t.string :method
      t.timestamps
    end
  end
end
