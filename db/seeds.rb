forums = ['有机食品', '基地水果', '澳洲进口']

forums.each do |forum|
  Forum.find_or_create_by_name(forum)
  puts "- #{forum} forumu oluşturuldu."
end
