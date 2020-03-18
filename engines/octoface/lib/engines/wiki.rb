# # unless ( File.basename($0) == 'rake')
#
# module Wiki
#   extend Octoface
#   octo_configure do
#     add(:engines_links) do
#       {
#         create_organization: Wiki::Page.where("url LIKE ?", '%organization%'),
#         comments_guide: Wiki::Page.where("url LIKE ?", '%comments_guide%')
#       }
#     end
#   end
# end
#
#
#   # Wiki.engines_links = {
#   #   create_organization: Wiki::Page.where("url LIKE ?", '%organization%'),
#   #   comments_guide: Wiki::Page.where("url LIKE ?", '%comments_guide%')
#   # }
# # end
