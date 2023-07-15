module Perf
  class ComparatorFormatter

    def self.call(rows)
      rows.group_by { |r| r['id'] }.transform_values do |project_rows|
        project_hash(project_rows)
      end
    end

    def self.project_hash(project_rows)
      (project_rows.map { |row| [row['state'], state_hash(row)] } +
      [['ALL', whole_hash(project_rows.first)]]).to_h
    end

    def self.state_hash(row)
      Comparator.selections.keys.map { |a| [a.to_s, attribute_hash(row, a)] }
                           .to_h
    end

    def self.attribute_hash(row, attribute)
      {
        'value' => row["s_#{attribute}"],
        'place' => row["s_place_#{attribute}"],
        'share_value' => row["s_share_#{attribute}"],
        'share_place' => row["s_share_place_#{attribute}"]
      }
    end

    def self.whole_hash(row)
      Comparator.selections.keys.map { |a| [a.to_s, whole_attribute_hash(row, a)] }
                .to_h
    end

    def self.whole_attribute_hash(row, attribute)
      {
        'value' => row["n_#{attribute}"],
        'place' => row["n_place_#{attribute}"]
      }
    end
  end
end
