# encoding: utf-8

module GraphBuilder
  extend ActiveSupport::Concern

  included do
    def self.to_chart
      chart = []
      if head = all.first
        ids = head.data.map { |c| c[0] }
        chart << ["Дата"].push(*head.data.map { |c| c[1] })
        all.map do |c|
          chart << [c.pub_date].push(*c.to_row(ids))
        end
      end
      chart.each do |row|
        row.collect! { |x| x.nil? ? 0 : x }
      end
    end

    def self.to_charts
      charts = {}
      max_row_size = all.map{|x| x.data.first[2].map(&:first).size}.max
      all.each do |cohort|
        ids = cohort.data.first[2].map(&:first)
        cohort.data.each do |group|
          charts[group[1]] ||= [["Дата"].push(*group[2].map { |d| d[1] })]
          datas = Array.new max_row_size, 0
          ids.map do |id|
            if val = group[2].find { |c| c[0] == id }
              val[2]
            end
          end.each_with_index { |x, i| datas[i] = x }
          charts[group[1]] << [cohort.pub_date].push(*datas)
        end
      end
      charts
    end
  end

  def pub_date
    I18n.l created_at, format: :long
  end

  def to_row(ids)
    ids.map do |id|
      if val = data.find { |c| c[0] == id }
        val[2]
      end
    end
  end
end
