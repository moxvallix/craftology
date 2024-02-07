ELEMENTS = "db/seeds/fixtures/elements.json".freeze

JSON.parse(File.read(ELEMENTS)).each do |name, description, icon, default|
  element = Element.find_by_name name
  if element.present?
    element.update(description: description, icon: icon, default: default)
    next
  end
  Element.create(name: name, description: description, icon: icon, default: default)
end