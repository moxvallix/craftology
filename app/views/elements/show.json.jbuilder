json.name element.name
json.icon element.icon
json.description element.description
json.discovered_by do
  json.name element.discoverer
  json.self own_discovery ||= false
end