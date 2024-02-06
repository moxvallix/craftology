ELEMENTS = [
  ["error", "The result of a failed experiment... Better luck next time!", "🚫"],
  ["earth", "Earth is our planet. Home to many diverse life forms.", "🌏", true],
  ["air", "Essential atmospheric gas mixture comprising oxygen, nitrogen & trace elements, vital for respiration & sustaining life", "🍃", true],
  ["fire", "Fire is an intense chemical reaction releasing heat, light, and often flames.", "🔥", true],
  ["water", "Essential clear liquid sustaining life, comprising H₂O molecules.", "💧", true],
  ["dirt", "Dispersed soil particles mixed with organic matter typically resulting from erosion or human activity; commonly seen as unclean substance.", "🪴"],
  ["atmosphere", "The atmosphere is the gaseous layer surrounding Earth, comprising oxygen, nitrogen, water vapor & trace elements essential for life support.", "🌃"],
  ["lava", "Lava is molten rock erupting from volcanoes or fissures, typically very hot & destructive.", "🔥"],
  ["plant", "A living organism rooted in soil, producing food via photosynthesis.", "🌱"],
  ["wind", "Wind is the natural air current resulting from atmospheric pressure differences & horizontal movement of gases.", "🍃"],
  ["smoke", "Visible airborne particulate matter created by burning or combustion.", "💨"],
  ["cloud", "Atmospheric water vapor condensation visible as a floating mass in the sky.", "☁️"],
  ["heat", "Energy transferred due to temperature difference resulting in molecular vibration.", "🔥"],
  ["steam", "Hot water vapor formed during heat conversion.", "♨"],
  ["ocean", "A vast salty water body covering 70% of Earth's surface; integral to life & climate systems.", "🌊"]
]

ELEMENTS.each do |name, description, icon, default|
  element = Element.find_by_name name
  return element.update(description: description, icon: icon, default: default) if element.present?
  Element.create(name: name, description: description, icon: icon, default: default)
end