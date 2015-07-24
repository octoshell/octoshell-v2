# encoding: utf-8

module Exportable
  extend ActiveSupport::Concern

  def generate_rtf
    font = ::RTF::Font.new(::RTF::Font::ROMAN, "Arial")

    styles = {}

    header = ::RTF::ParagraphStyle.new
    header.justification = :qr
    header.space_before = 300
    header.space_after = 300
    styles["header"] = header

    title = ::RTF::ParagraphStyle.new
    title.space_before = 1000
    title.space_after = 1000
    title.justification = :qc
    styles["title"] = title

    body = ::RTF::ParagraphStyle.new
    body.justification = :qj
    body.space_after = 300
    styles["body"] = body

    dl = ::RTF::ParagraphStyle.new
    dl.space_after = 100
    dl.left_indent = 500
    styles["dl"] = dl

    dd = ::RTF::ParagraphStyle.new
    dd.space_after = 100
    dd.left_indent = 800
    styles["dd"] = dd

    footer = ::RTF::ParagraphStyle.new
    footer.space_before = 300
    styles["footer"] = footer

    document = ::RTF::Document.new(font)

    template = YAML.load_file("#{Core::Engine.root}/config/sureties/surety.rtf")

    replacer = lambda do |text|
      text.gsub! %r{\{\{ id \}\}}, id.to_s
      text.gsub! %r{\{\{ organization_name \}\}},     full_organization_name
      text.gsub! %r{\{\{ boss_full_name \}\}},        boss_full_name || ""
      text.gsub! %r{\{\{ boss_position \}\}},         boss_position || ""
      text.gsub! %r{\{\{ members \}\}},               surety_members.where.not(user_id: nil).map(&:full_name).join("\\line")
      text.gsub! %r{\{\{ other_organizations \}\}},   surety_members.map(&:organization).compact.uniq.map(&:name).join("\\line")
      text.gsub! %r{\{\{ project_name \}\}},          project.try(:title) || "Не указан"
      text.gsub! %r{\{\{ direction_of_sciences \}\}}, project.direction_of_sciences.map(&:name).join("\\line")
      text.gsub! %r{\{\{ critical_technologies \}\}}, project.critical_technologies.map(&:name).join("\\line")
      text.gsub! %r{\{\{ research_area \}\}},         project.research_areas.map(&:name).join("\\line")
      text.gsub! %r{\{\{ project_description \}\}},   project.card.try(:objective) || "Не указано"
      text.gsub! %r{\{\{ date \}\}},                  I18n.l(Date.current)
      text
    end

    document.paragraph(styles["body"]) do |p|
      5.times { p.line_break }
    end

    template.each do |node|
      style, content = node["style"], node["content"]
      document.paragraph(styles[style]) do |p|
        if content.is_a?(Array)
          content.each do |n|
            p << replacer.call(n)
            p.line_break
          end
        else
          p << replacer.call(content)
        end
      end
    end

    document.to_rtf
  end
end
