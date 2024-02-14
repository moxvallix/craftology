Rails.application.config.after_initialize do
  user = User.find_by_email(ENV["ADMIN_USER_EMAIL"])
  user.update(admin: true) if user.present?
end
