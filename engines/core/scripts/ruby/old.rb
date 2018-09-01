names = User.reflect_on_all_associations.map(&:name) - %i[profile groups user_groups]
head = %w[id email access_state] + names
pending_users_info = [ head ]

User.where("activation_state = 'pending'").each do |user|
  assocs = names.select { |name| user.send(name) }
                .map{ |a| [a, user.send(a).to_a] }.select { |a| a.second.any?}
  next if assocs.empty?
  # puts assocs.inspect
  element = [user.id, user.email, user.access_state]
  names.each do |name|
   arr = assocs.detect { |a| a.first == name }
   arr ? (element << arr.second) : (element << nil)
  end
  pending_users_info << element
end
workbook = WriteXLSX.new('delete_users.xlsx')
worksheet = workbook.add_worksheet
pending_users_info.each_with_index do |row, i|
  row.each_with_index do |column, j|
    worksheet.write(i, j, column)
  end
end
workbook.close
