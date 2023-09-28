puts 'Rebuilding positions'

ActiveRecord::Base.transaction do
  Core::EmploymentPosition.left_outer_joins(:employment)
                          .where(core_employments: { id: nil }).destroy_all

  Core::EmploymentPositionName.all.each do |position_name|
    Core::EmploymentPosition.where(name: position_name.name_ru)
                            .update_all(employment_position_name_id: position_name.id)
    if position_name.name == 'Номер группы (для студентов МГУ)'
      Core::EmploymentPosition.where(name: 'Группа')
                              .update_all(employment_position_name_id: position_name.id)
    end
  end
end


ActiveRecord::Base.transaction do
  Core::EmploymentPositionField.destroy_all
  Core::EmploymentPositionName.where("autocomplete is NOT NULL AND autocomplete != ''")
                              .each do |position_name|
                                position_name.autocomplete.split("\r\n").uniq.each do |field|
                                  field2 = Core::EmploymentPositionField.create!(employment_position_name: position_name,
                                                                                name_ru: field)
                                  Core::EmploymentPosition.where(name: position_name.name_ru)
                                                          .where("VALUE LIKE '#{field}%'")
                                                          .update_all(field_id: field2.id )
                                end
  end
end
