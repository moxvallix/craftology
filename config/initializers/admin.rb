Rails.application.config.after_initialize do
  begin
    user = User.find_by_email(ENV["ADMIN_USER_EMAIL"])
    user.update(admin: true) if user.present?
  rescue
  end
end
