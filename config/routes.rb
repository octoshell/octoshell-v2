# == Route Map
#
#                      Prefix Verb   URI Pattern                                  Controller#Action
#         rails_email_preview        /admin/emails                                RailsEmailPreview::Engine
#                         api        /api                                         Api::Engine
#                        wiki        /wiki                                        Wiki::Engine
#                     jobstat        /jobstat                                     Jobstat::Engine
#                  statistics        /admin/stats                                 Statistics::Engine
#                    sessions        /sessions                                    Sessions::Engine
#                     support        /support                                     Support::Engine
#                        core        /core                                        Core::Engine
#                        face        /                                            Face::Engine
#              authentication        /auth                                        Authentication::Engine
#                        pack        /pack                                        Pack::Engine
#               announcements        /announcements                               Announcements::Engine
#                    comments        /comments                                    Comments::Engine
#                    hardware        /hardware                                    Hardware::Engine
#                        root GET    /                                            face/home#show
#               login_as_user GET    /users/:id/login_as(.:format)                users#login_as
#         return_to_self_user GET    /users/:id/return_to_self(.:format)          users#return_to_self
#                       users GET    /users(.:format)                             users#index
#                             POST   /users(.:format)                             users#create
#                    new_user GET    /users/new(.:format)                         users#new
#                   edit_user GET    /users/:id/edit(.:format)                    users#edit
#                        user GET    /users/:id(.:format)                         users#show
#                             PATCH  /users/:id(.:format)                         users#update
#                             PUT    /users/:id(.:format)                         users#update
#                             DELETE /users/:id(.:format)                         users#destroy
#           change_lang_prefs POST   /lang_prefs/change(.:format)                 lang_prefs#change
#                     profile POST   /profile(.:format)                           profiles#create
#                 new_profile GET    /profile/new(.:format)                       profiles#new
#                edit_profile GET    /profile/edit(.:format)                      profiles#edit
#                             GET    /profile(.:format)                           profiles#show
#                             PATCH  /profile(.:format)                           profiles#update
#                             PUT    /profile(.:format)                           profiles#update
#                             DELETE /profile(.:format)                           profiles#destroy
#          categories_options GET    /options/categories(.:format)                options#categories
#               values_option GET    /options/:id/values(.:format)                options#values
#           admin_sidekiq_web        /admin/sidekiq                               Sidekiq::Web
#     block_access_admin_user POST   /admin/users/:id/block_access(.:format)      admin/users#block_access
#   unblock_access_admin_user POST   /admin/users/:id/unblock_access(.:format)    admin/users#unblock_access
#                 admin_users GET    /admin/users(.:format)                       admin/users#index
#                             POST   /admin/users(.:format)                       admin/users#create
#              new_admin_user GET    /admin/users/new(.:format)                   admin/users#new
#             edit_admin_user GET    /admin/users/:id/edit(.:format)              admin/users#edit
#                  admin_user GET    /admin/users/:id(.:format)                   admin/users#show
#                             PATCH  /admin/users/:id(.:format)                   admin/users#update
#                             PUT    /admin/users/:id(.:format)                   admin/users#update
#                             DELETE /admin/users/:id(.:format)                   admin/users#destroy
#        default_admin_groups PUT    /admin/groups/default(.:format)              admin/groups#default
#                admin_groups GET    /admin/groups(.:format)                      admin/groups#index
#                             POST   /admin/groups(.:format)                      admin/groups#create
#             new_admin_group GET    /admin/groups/new(.:format)                  admin/groups#new
#            edit_admin_group GET    /admin/groups/:id/edit(.:format)             admin/groups#edit
#                 admin_group GET    /admin/groups/:id(.:format)                  admin/groups#show
#                             PATCH  /admin/groups/:id(.:format)                  admin/groups#update
#                             PUT    /admin/groups/:id(.:format)                  admin/groups#update
#                             DELETE /admin/groups/:id(.:format)                  admin/groups#destroy
#    admin_options_categories GET    /admin/options_categories(.:format)          admin/options_categories#index
#                             POST   /admin/options_categories(.:format)          admin/options_categories#create
#  new_admin_options_category GET    /admin/options_categories/new(.:format)      admin/options_categories#new
# edit_admin_options_category GET    /admin/options_categories/:id/edit(.:format) admin/options_categories#edit
#      admin_options_category GET    /admin/options_categories/:id(.:format)      admin/options_categories#show
#                             PATCH  /admin/options_categories/:id(.:format)      admin/options_categories#update
#                             PUT    /admin/options_categories/:id(.:format)      admin/options_categories#update
#                             DELETE /admin/options_categories/:id(.:format)      admin/options_categories#destroy
#                    rails_db        /rails/db                                    RailsDb::Engine
#
# Routes for RailsEmailPreview::Engine:
#               rep_emails GET  /(:email_locale)(.:format)                                   rails_email_preview/emails#index {:email_locale=>/ru|en/}
#                rep_email GET  (/:email_locale)/:preview_id(/:part_type)(.:format)          rails_email_preview/emails#show {:email_locale=>/ru|en/, :part_type=>/html|plain|raw/, :preview_id=>/\w+-\w+/}
#            rep_raw_email GET  (/:email_locale)/:preview_id(/:part_type)/body(.:format)     rails_email_preview/emails#show_body {:email_locale=>/ru|en/, :part_type=>/html|plain|raw/, :preview_id=>/\w+-\w+/}
#         rep_test_deliver POST (/:email_locale)/:preview_id/deliver(.:format)               rails_email_preview/emails#test_deliver {:email_locale=>/ru|en/, :preview_id=>/\w+-\w+/}
# rep_raw_email_attachment GET  (/:email_locale)/:preview_id/attachments/:filename(.:format) rails_email_preview/emails#show_attachment {:email_locale=>/ru|en/, :preview_id=>/\w+-\w+/}
#        rep_email_headers GET  (/:email_locale)/:preview_id/headers(.:format)               rails_email_preview/emails#show_headers {:email_locale=>/ru|en/, :preview_id=>/\w+-\w+/}
#                 rep_root GET  /(:email_locale)(.:format)                                   rails_email_preview/emails#index {:email_locale=>/ru|en/}
#
# Routes for Api::Engine:
#    abilities GET    /abilities(.:format)          api/abilities#index
#              POST   /abilities(.:format)          api/abilities#create
#  new_ability GET    /abilities/new(.:format)      api/abilities#new
# edit_ability GET    /abilities/:id/edit(.:format) api/abilities#edit
#      ability GET    /abilities/:id(.:format)      api/abilities#show
#              PATCH  /abilities/:id(.:format)      api/abilities#update
#              PUT    /abilities/:id(.:format)      api/abilities#update
#              DELETE /abilities/:id(.:format)      api/abilities#destroy
#      exports GET    /exports(.:format)            api/exports#index
#              POST   /exports(.:format)            api/exports#create
#   new_export GET    /exports/new(.:format)        api/exports#new
#  edit_export GET    /exports/:id/edit(.:format)   api/exports#edit
#       export GET    /exports/:id(.:format)        api/exports#show
#              PATCH  /exports/:id(.:format)        api/exports#update
#              PUT    /exports/:id(.:format)        api/exports#update
#              DELETE /exports/:id(.:format)        api/exports#destroy
#
# Routes for Wiki::Engine:
#     tasks GET    /tasks(.:format)          wiki/tasks#index
#           POST   /tasks(.:format)          wiki/tasks#create
#  new_task GET    /tasks/new(.:format)      wiki/tasks#new
# edit_task GET    /tasks/:id/edit(.:format) wiki/tasks#edit
#      task GET    /tasks/:id(.:format)      wiki/tasks#show
#           PATCH  /tasks/:id(.:format)      wiki/tasks#update
#           PUT    /tasks/:id(.:format)      wiki/tasks#update
#           DELETE /tasks/:id(.:format)      wiki/tasks#destroy
#     pages GET    /pages(.:format)          wiki/pages#index
#           POST   /pages(.:format)          wiki/pages#create
#  new_page GET    /pages/new(.:format)      wiki/pages#new
# edit_page GET    /pages/:id/edit(.:format) wiki/pages#edit
#      page GET    /pages/:id(.:format)      wiki/pages#show
#           PATCH  /pages/:id(.:format)      wiki/pages#update
#           PUT    /pages/:id(.:format)      wiki/pages#update
#           DELETE /pages/:id(.:format)      wiki/pages#destroy
#      root GET    /                         wiki/pages#index
#
# Routes for Jobstat::Engine:
#       account_list_index GET    /account/list/index(.:format)        jobstat/account_list#index
#   account_list_all_rules GET    /account/list/all_rules(.:format)    jobstat/account_list#all_rules
#    account_list_feedback POST   /account/list/feedback(.:format)     jobstat/account_list#feedback
#             job_feedback POST   /job/feedback(.:format)              jobstat/account_list#feedback
#     account_summary_show GET    /account/summary/show(.:format)      jobstat/account_summary#show
# account_summary_download GET    /account/summary/download(.:format)  jobstat/account_summary#download
#                job_index GET    /job(.:format)                       jobstat/job#index
#                          POST   /job(.:format)                       jobstat/job#create
#                  new_job GET    /job/new(.:format)                   jobstat/job#new
#                 edit_job GET    /job/:id/edit(.:format)              jobstat/job#edit
#                      job GET    /job/:id(.:format)                   jobstat/job#show
#                          PATCH  /job/:id(.:format)                   jobstat/job#update
#                          PUT    /job/:id(.:format)                   jobstat/job#update
#                          DELETE /job/:id(.:format)                   jobstat/job#destroy
#                          GET    /job/:cluster/:drms_job_id(.:format) jobstat/job#show_direct
#                 job_info POST   /job/info(.:format)                  jobstat/api#post_info
#          job_performance POST   /job/performance(.:format)           jobstat/api#post_performance
#               job_digest POST   /job/digest(.:format)                jobstat/api#post_digest
#                 job_tags POST   /job/tags(.:format)                  jobstat/api#post_tags
#
# Routes for Statistics::Engine:
#         calculate_stats_users POST /users/calculate_stats(.:format)         statistics/users#calculate_stats
#                         users GET  /users(.:format)                         statistics/users#index
#      calculate_stats_projects POST /projects/calculate_stats(.:format)      statistics/projects#calculate_stats
#                      projects GET  /projects(.:format)                      statistics/projects#index
# calculate_stats_organizations POST /organizations/calculate_stats(.:format) statistics/organizations#calculate_stats
#                 organizations GET  /organizations(.:format)                 statistics/organizations#index
#      calculate_stats_sessions POST /sessions/calculate_stats(.:format)      statistics/sessions#calculate_stats
#                      sessions GET  /sessions(.:format)                      statistics/sessions#index
#
# Routes for Sessions::Engine:
#                          report_accept PUT    /reports/:report_id/accept(.:format)                   sessions/reports#accept
#              report_decline_submitting PUT    /reports/:report_id/decline_submitting(.:format)       sessions/reports#decline_submitting
#                          report_submit PATCH  /reports/:report_id/submit(.:format)                   sessions/reports#submit
#                        report_resubmit PATCH  /reports/:report_id/resubmit(.:format)                 sessions/reports#resubmit
#                         report_replies POST   /reports/:report_id/replies(.:format)                  sessions/reports#replies
#                                reports GET    /reports(.:format)                                     sessions/reports#index
#                            edit_report GET    /reports/:id/edit(.:format)                            sessions/reports#edit
#                                 report GET    /reports/:id(.:format)                                 sessions/reports#show
#                                        PATCH  /reports/:id(.:format)                                 sessions/reports#update
#                                        PUT    /reports/:id(.:format)                                 sessions/reports#update
#                     user_survey_accept PUT    /surveys/:user_survey_id/accept(.:format)              sessions/user_surveys#accept
#                     user_survey_submit PATCH  /surveys/:user_survey_id/submit(.:format)              sessions/user_surveys#submit
#                           user_surveys GET    /surveys(.:format)                                     sessions/user_surveys#index
#                       edit_user_survey GET    /surveys/:id/edit(.:format)                            sessions/user_surveys#edit
#                            user_survey GET    /surveys/:id(.:format)                                 sessions/user_surveys#show
#                                        PATCH  /surveys/:id(.:format)                                 sessions/user_surveys#update
#                                        PUT    /surveys/:id(.:format)                                 sessions/user_surveys#update
#                      admin_report_pick PATCH  /admin/reports/:report_id/pick(.:format)               sessions/admin/reports#pick
#                    admin_report_assess PATCH  /admin/reports/:report_id/assess(.:format)             sessions/admin/reports#assess
#                    admin_report_reject PATCH  /admin/reports/:report_id/reject(.:format)             sessions/admin/reports#reject
#                      admin_report_edit PUT    /admin/reports/:report_id/edit(.:format)               sessions/admin/reports#edit
#                   admin_report_replies POST   /admin/reports/:report_id/replies(.:format)            sessions/admin/reports#replies
#             admin_report_change_expert PATCH  /admin/reports/:report_id/change_expert(.:format)      sessions/admin/reports#change_expert
#                          admin_reports GET    /admin/reports(.:format)                               sessions/admin/reports#index
#                           admin_report GET    /admin/reports/:id(.:format)                           sessions/admin/reports#show
#     admin_report_submit_denial_reasons GET    /admin/report_submit_denial_reasons(.:format)          sessions/admin/report_submit_denial_reasons#index
#                                        POST   /admin/report_submit_denial_reasons(.:format)          sessions/admin/report_submit_denial_reasons#create
#  new_admin_report_submit_denial_reason GET    /admin/report_submit_denial_reasons/new(.:format)      sessions/admin/report_submit_denial_reasons#new
# edit_admin_report_submit_denial_reason GET    /admin/report_submit_denial_reasons/:id/edit(.:format) sessions/admin/report_submit_denial_reasons#edit
#      admin_report_submit_denial_reason GET    /admin/report_submit_denial_reasons/:id(.:format)      sessions/admin/report_submit_denial_reasons#show
#                                        PATCH  /admin/report_submit_denial_reasons/:id(.:format)      sessions/admin/report_submit_denial_reasons#update
#                                        PUT    /admin/report_submit_denial_reasons/:id(.:format)      sessions/admin/report_submit_denial_reasons#update
#                                        DELETE /admin/report_submit_denial_reasons/:id(.:format)      sessions/admin/report_submit_denial_reasons#destroy
#                    admin_session_start PUT    /admin/sessions/:session_id/start(.:format)            sessions/admin/sessions#start
#                     admin_session_stop PUT    /admin/sessions/:session_id/stop(.:format)             sessions/admin/sessions#stop
#                 admin_session_download PUT    /admin/sessions/:session_id/download(.:format)         sessions/admin/sessions#download
#            admin_session_show_projects GET    /admin/sessions/:session_id/show_projects(.:format)    sessions/admin/sessions#show_projects
#          admin_session_select_projects POST   /admin/sessions/:session_id/select_projects(.:format)  sessions/admin/sessions#select_projects
#                    admin_session_stats GET    /admin/sessions/:session_id/stats(.:format)            sessions/admin/stats#index {:expect=>[:index, :show]}
#                                        POST   /admin/sessions/:session_id/stats(.:format)            sessions/admin/stats#create {:expect=>[:index, :show]}
#                 new_admin_session_stat GET    /admin/sessions/:session_id/stats/new(.:format)        sessions/admin/stats#new {:expect=>[:index, :show]}
#                edit_admin_session_stat GET    /admin/sessions/:session_id/stats/:id/edit(.:format)   sessions/admin/stats#edit {:expect=>[:index, :show]}
#                     admin_session_stat GET    /admin/sessions/:session_id/stats/:id(.:format)        sessions/admin/stats#show {:expect=>[:index, :show]}
#                                        PATCH  /admin/sessions/:session_id/stats/:id(.:format)        sessions/admin/stats#update {:expect=>[:index, :show]}
#                                        PUT    /admin/sessions/:session_id/stats/:id(.:format)        sessions/admin/stats#update {:expect=>[:index, :show]}
#                                        DELETE /admin/sessions/:session_id/stats/:id(.:format)        sessions/admin/stats#destroy {:expect=>[:index, :show]}
#                  admin_session_surveys POST   /admin/sessions/:session_id/surveys(.:format)          sessions/admin/surveys#create
#               new_admin_session_survey GET    /admin/sessions/:session_id/surveys/new(.:format)      sessions/admin/surveys#new
#              edit_admin_session_survey GET    /admin/sessions/:session_id/surveys/:id/edit(.:format) sessions/admin/surveys#edit
#                   admin_session_survey PATCH  /admin/sessions/:session_id/surveys/:id(.:format)      sessions/admin/surveys#update
#                                        PUT    /admin/sessions/:session_id/surveys/:id(.:format)      sessions/admin/surveys#update
#                         admin_sessions GET    /admin/sessions(.:format)                              sessions/admin/sessions#index
#                                        POST   /admin/sessions(.:format)                              sessions/admin/sessions#create
#                      new_admin_session GET    /admin/sessions/new(.:format)                          sessions/admin/sessions#new
#                          admin_session GET    /admin/sessions/:id(.:format)                          sessions/admin/sessions#show
#                    admin_stat_download GET    /admin/stats/:stat_id/download(.:format)               sessions/admin/stats#download
#                      admin_stat_detail GET    /admin/stats/:stat_id/detail(.:format)                 sessions/admin/stats#detail
#             admin_survey_survey_fields POST   /admin/surveys/:survey_id/fields(.:format)             sessions/admin/survey_fields#create
#          new_admin_survey_survey_field GET    /admin/surveys/:survey_id/fields/new(.:format)         sessions/admin/survey_fields#new
#         edit_admin_survey_survey_field GET    /admin/surveys/:survey_id/fields/:id/edit(.:format)    sessions/admin/survey_fields#edit
#              admin_survey_survey_field GET    /admin/surveys/:survey_id/fields/:id(.:format)         sessions/admin/survey_fields#show
#                                        PATCH  /admin/surveys/:survey_id/fields/:id(.:format)         sessions/admin/survey_fields#update
#                                        PUT    /admin/surveys/:survey_id/fields/:id(.:format)         sessions/admin/survey_fields#update
#                                        DELETE /admin/surveys/:survey_id/fields/:id(.:format)         sessions/admin/survey_fields#destroy
#                          admin_surveys POST   /admin/surveys(.:format)                               sessions/admin/surveys#create
#                       new_admin_survey GET    /admin/surveys/new(.:format)                           sessions/admin/surveys#new
#                           admin_survey GET    /admin/surveys/:id(.:format)                           sessions/admin/surveys#show
#                                        DELETE /admin/surveys/:id(.:format)                           sessions/admin/surveys#destroy
#                      admin_user_survey GET    /admin/user_surveys/:id(.:format)                      sessions/admin/user_surveys#show
#                             admin_root GET    /admin(.:format)                                       sessions/admin/sessions#index
#                                   root GET    /                                                      sessions/reports#index
#
# Routes for Support::Engine:
#            admin_ticket_close PUT    /admin/tickets/:ticket_id/close(.:format)     support/admin/tickets#close
#           admin_ticket_reopen PUT    /admin/tickets/:ticket_id/reopen(.:format)    support/admin/tickets#reopen
#           admin_ticket_accept POST   /admin/tickets/:ticket_id/accept(.:format)    support/admin/tickets#accept
# edit_responsible_admin_ticket PUT    /admin/tickets/:id/edit_responsible(.:format) support/admin/tickets#edit_responsible
#                 admin_tickets GET    /admin/tickets(.:format)                      support/admin/tickets#index
#                               POST   /admin/tickets(.:format)                      support/admin/tickets#create
#              new_admin_ticket GET    /admin/tickets/new(.:format)                  support/admin/tickets#new
#             edit_admin_ticket GET    /admin/tickets/:id/edit(.:format)             support/admin/tickets#edit
#                  admin_ticket GET    /admin/tickets/:id(.:format)                  support/admin/tickets#show
#                               PATCH  /admin/tickets/:id(.:format)                  support/admin/tickets#update
#                               PUT    /admin/tickets/:id(.:format)                  support/admin/tickets#update
#                 admin_replies POST   /admin/replies(.:format)                      support/admin/replies#create
#         admin_reply_templates GET    /admin/reply_templates(.:format)              support/admin/reply_templates#index
#                               POST   /admin/reply_templates(.:format)              support/admin/reply_templates#create
#      new_admin_reply_template GET    /admin/reply_templates/new(.:format)          support/admin/reply_templates#new
#     edit_admin_reply_template GET    /admin/reply_templates/:id/edit(.:format)     support/admin/reply_templates#edit
#          admin_reply_template GET    /admin/reply_templates/:id(.:format)          support/admin/reply_templates#show
#                               PATCH  /admin/reply_templates/:id(.:format)          support/admin/reply_templates#update
#                               PUT    /admin/reply_templates/:id(.:format)          support/admin/reply_templates#update
#                               DELETE /admin/reply_templates/:id(.:format)          support/admin/reply_templates#destroy
#                  admin_topics GET    /admin/topics(.:format)                       support/admin/topics#index
#                               POST   /admin/topics(.:format)                       support/admin/topics#create
#               new_admin_topic GET    /admin/topics/new(.:format)                   support/admin/topics#new
#              edit_admin_topic GET    /admin/topics/:id/edit(.:format)              support/admin/topics#edit
#                   admin_topic GET    /admin/topics/:id(.:format)                   support/admin/topics#show
#                               PATCH  /admin/topics/:id(.:format)                   support/admin/topics#update
#                               PUT    /admin/topics/:id(.:format)                   support/admin/topics#update
#                               DELETE /admin/topics/:id(.:format)                   support/admin/topics#destroy
#                  admin_fields GET    /admin/fields(.:format)                       support/admin/fields#index
#                               POST   /admin/fields(.:format)                       support/admin/fields#create
#               new_admin_field GET    /admin/fields/new(.:format)                   support/admin/fields#new
#              edit_admin_field GET    /admin/fields/:id/edit(.:format)              support/admin/fields#edit
#                   admin_field GET    /admin/fields/:id(.:format)                   support/admin/fields#show
#                               PATCH  /admin/fields/:id(.:format)                   support/admin/fields#update
#                               PUT    /admin/fields/:id(.:format)                   support/admin/fields#update
#                               DELETE /admin/fields/:id(.:format)                   support/admin/fields#destroy
#               admin_tag_merge PUT    /admin/tags/:tag_id/merge(.:format)           support/admin/tags#merge
#                    admin_tags GET    /admin/tags(.:format)                         support/admin/tags#index
#                               POST   /admin/tags(.:format)                         support/admin/tags#create
#                 new_admin_tag GET    /admin/tags/new(.:format)                     support/admin/tags#new
#                edit_admin_tag GET    /admin/tags/:id/edit(.:format)                support/admin/tags#edit
#                     admin_tag GET    /admin/tags/:id(.:format)                     support/admin/tags#show
#                               PATCH  /admin/tags/:id(.:format)                     support/admin/tags#update
#                               PUT    /admin/tags/:id(.:format)                     support/admin/tags#update
#                    admin_root GET    /admin(.:format)                              support/admin/tickets#index
#              continue_tickets POST   /tickets/continue(.:format)                   support/tickets#continue
#                  ticket_close PUT    /tickets/:ticket_id/close(.:format)           support/tickets#close
#                ticket_resolve PUT    /tickets/:ticket_id/resolve(.:format)         support/tickets#resolve
#                 ticket_reopen PUT    /tickets/:ticket_id/reopen(.:format)          support/tickets#reopen
#                       tickets GET    /tickets(.:format)                            support/tickets#index
#                               POST   /tickets(.:format)                            support/tickets#create
#                    new_ticket GET    /tickets/new(.:format)                        support/tickets#new
#                   edit_ticket GET    /tickets/:id/edit(.:format)                   support/tickets#edit
#                        ticket GET    /tickets/:id(.:format)                        support/tickets#show
#                               PATCH  /tickets/:id(.:format)                        support/tickets#update
#                               PUT    /tickets/:id(.:format)                        support/tickets#update
#                       replies POST   /replies(.:format)                            support/replies#create
#                          root GET    /                                             support/tickets#index
#
# Routes for Core::Engine:
#                             admin_members GET    /admin/members(.:format)                                             core/admin/members#index
#                    activate_admin_project GET    /admin/projects/:id/activate(.:format)                               core/admin/projects#activate
#                      cancel_admin_project GET    /admin/projects/:id/cancel(.:format)                                 core/admin/projects#cancel
#                     suspend_admin_project GET    /admin/projects/:id/suspend(.:format)                                core/admin/projects#suspend
#                       block_admin_project GET    /admin/projects/:id/block(.:format)                                  core/admin/projects#block
#                     unblock_admin_project GET    /admin/projects/:id/unblock(.:format)                                core/admin/projects#unblock
#                  reactivate_admin_project GET    /admin/projects/:id/reactivate(.:format)                             core/admin/projects#reactivate
#                      finish_admin_project GET    /admin/projects/:id/finish(.:format)                                 core/admin/projects#finish
#                   resurrect_admin_project GET    /admin/projects/:id/resurrect(.:format)                              core/admin/projects#resurrect
#   synchronize_with_clusters_admin_project GET    /admin/projects/:id/synchronize_with_clusters(.:format)              core/admin/projects#synchronize_with_clusters
#                    admin_project_requests POST   /admin/projects/:project_id/requests(.:format)                       core/admin/requests#create
#                 new_admin_project_request GET    /admin/projects/:project_id/requests/new(.:format)                   core/admin/requests#new
#                            admin_projects GET    /admin/projects(.:format)                                            core/admin/projects#index
#                                           POST   /admin/projects(.:format)                                            core/admin/projects#create
#                         new_admin_project GET    /admin/projects/new(.:format)                                        core/admin/projects#new
#                        edit_admin_project GET    /admin/projects/:id/edit(.:format)                                   core/admin/projects#edit
#                             admin_project GET    /admin/projects/:id(.:format)                                        core/admin/projects#show
#                                           PATCH  /admin/projects/:id(.:format)                                        core/admin/projects#update
#                                           PUT    /admin/projects/:id(.:format)                                        core/admin/projects#update
#                                           DELETE /admin/projects/:id(.:format)                                        core/admin/projects#destroy
#                       find_admin_sureties POST   /admin/sureties/find(.:format)                                       core/admin/sureties#find
#                   template_admin_sureties GET    /admin/sureties/template(.:format)                                   core/admin/sureties#edit_template
#                                           PUT    /admin/sureties/template(.:format)                                   core/admin/sureties#update_template
#                    default_admin_sureties PUT    /admin/sureties/default(.:format)                                    core/admin/sureties#default_template
#               rtf_template_admin_sureties PUT    /admin/sureties/rtf_template(.:format)                               core/admin/sureties#rtf_template
#                default_rtf_admin_sureties PUT    /admin/sureties/default_rtf(.:format)                                core/admin/sureties#default_rtf
#                                           GET    /admin/sureties/rtf_template(.:format)                               core/admin/sureties#download_rtf_template
#                     admin_surety_activate PUT    /admin/sureties/:surety_id/activate(.:format)                        core/admin/sureties#activate
#                        admin_surety_close PUT    /admin/sureties/:surety_id/close(.:format)                           core/admin/sureties#close
#                      admin_surety_confirm PUT    /admin/sureties/:surety_id/confirm(.:format)                         core/admin/sureties#confirm
#                       admin_surety_reject PUT    /admin/sureties/:surety_id/reject(.:format)                          core/admin/sureties#reject
#           admin_surety_activate_or_reject PUT    /admin/sureties/:surety_id/activate_or_reject(.:format)              core/admin/sureties#activate_or_reject
#                            admin_sureties GET    /admin/sureties(.:format)                                            core/admin/sureties#index
#                                           POST   /admin/sureties(.:format)                                            core/admin/sureties#create
#                          new_admin_surety GET    /admin/sureties/new(.:format)                                        core/admin/sureties#new
#                         edit_admin_surety GET    /admin/sureties/:id/edit(.:format)                                   core/admin/sureties#edit
#                              admin_surety GET    /admin/sureties/:id(.:format)                                        core/admin/sureties#show
#                                           PATCH  /admin/sureties/:id(.:format)                                        core/admin/sureties#update
#                                           PUT    /admin/sureties/:id(.:format)                                        core/admin/sureties#update
#                                           DELETE /admin/sureties/:id(.:format)                                        core/admin/sureties#destroy
#                       admin_project_kinds GET    /admin/project_kinds(.:format)                                       core/admin/project_kinds#index
#                                           POST   /admin/project_kinds(.:format)                                       core/admin/project_kinds#create
#                    new_admin_project_kind GET    /admin/project_kinds/new(.:format)                                   core/admin/project_kinds#new
#                   edit_admin_project_kind GET    /admin/project_kinds/:id/edit(.:format)                              core/admin/project_kinds#edit
#                        admin_project_kind GET    /admin/project_kinds/:id(.:format)                                   core/admin/project_kinds#show
#                                           PATCH  /admin/project_kinds/:id(.:format)                                   core/admin/project_kinds#update
#                                           PUT    /admin/project_kinds/:id(.:format)                                   core/admin/project_kinds#update
#                                           DELETE /admin/project_kinds/:id(.:format)                                   core/admin/project_kinds#destroy
#                  admin_organization_kinds GET    /admin/organization_kinds(.:format)                                  core/admin/organization_kinds#index
#                                           POST   /admin/organization_kinds(.:format)                                  core/admin/organization_kinds#create
#               new_admin_organization_kind GET    /admin/organization_kinds/new(.:format)                              core/admin/organization_kinds#new
#              edit_admin_organization_kind GET    /admin/organization_kinds/:id/edit(.:format)                         core/admin/organization_kinds#edit
#                   admin_organization_kind GET    /admin/organization_kinds/:id(.:format)                              core/admin/organization_kinds#show
#                                           PATCH  /admin/organization_kinds/:id(.:format)                              core/admin/organization_kinds#update
#                                           PUT    /admin/organization_kinds/:id(.:format)                              core/admin/organization_kinds#update
#                                           DELETE /admin/organization_kinds/:id(.:format)                              core/admin/organization_kinds#destroy
#                           admin_countries GET    /admin/countries(.:format)                                           core/admin/countries#index
#                                           POST   /admin/countries(.:format)                                           core/admin/countries#create
#                         new_admin_country GET    /admin/countries/new(.:format)                                       core/admin/countries#new
#                        edit_admin_country GET    /admin/countries/:id/edit(.:format)                                  core/admin/countries#edit
#                             admin_country GET    /admin/countries/:id(.:format)                                       core/admin/countries#show
#                                           PATCH  /admin/countries/:id(.:format)                                       core/admin/countries#update
#                                           PUT    /admin/countries/:id(.:format)                                       core/admin/countries#update
#                                           DELETE /admin/countries/:id(.:format)                                       core/admin/countries#destroy
#                          merge_admin_city POST   /admin/cities/:id/merge(.:format)                                    core/admin/cities#merge
#                              admin_cities GET    /admin/cities(.:format)                                              core/admin/cities#index
#                                           POST   /admin/cities(.:format)                                              core/admin/cities#create
#                            new_admin_city GET    /admin/cities/new(.:format)                                          core/admin/cities#new
#                           edit_admin_city GET    /admin/cities/:id/edit(.:format)                                     core/admin/cities#edit
#                                admin_city GET    /admin/cities/:id(.:format)                                          core/admin/cities#show
#                                           PATCH  /admin/cities/:id(.:format)                                          core/admin/cities#update
#                                           PUT    /admin/cities/:id(.:format)                                          core/admin/cities#update
#                                           DELETE /admin/cities/:id(.:format)                                          core/admin/cities#destroy
#                       admin_prepare_merge DELETE /admin/prepare_merge/:id(.:format)                                   core/admin/prepare_merge#destroy
#                 admin_prepare_merge_index GET    /admin/prepare_merge(.:format)                                       core/admin/prepare_merge#index
#                  edit_admin_prepare_merge GET    /admin/prepare_merge/:id/edit(.:format)                              core/admin/prepare_merge#edit
#                                           PATCH  /admin/prepare_merge/:id(.:format)                                   core/admin/prepare_merge#update
#                                           PUT    /admin/prepare_merge/:id(.:format)                                   core/admin/prepare_merge#update
# index_for_organization_admin_organization GET    /admin/organizations/:id/index_for_organization(.:format)            core/admin/organizations#index_for_organization
#                  check_admin_organization PUT    /admin/organizations/:id/check(.:format)                             core/admin/organizations#check
#            merge_edit_admin_organizations GET    /admin/organizations/merge_edit(.:format)                            core/admin/organizations#merge_edit
#          merge_update_admin_organizations POST   /admin/organizations/merge_update(.:format)                          core/admin/organizations#merge_update
#            admin_organization_departments GET    /admin/organizations/:organization_id/departments(.:format)          core/admin/departments#index
#                                           POST   /admin/organizations/:organization_id/departments(.:format)          core/admin/departments#create
#         new_admin_organization_department GET    /admin/organizations/:organization_id/departments/new(.:format)      core/admin/departments#new
#        edit_admin_organization_department GET    /admin/organizations/:organization_id/departments/:id/edit(.:format) core/admin/departments#edit
#             admin_organization_department PATCH  /admin/organizations/:organization_id/departments/:id(.:format)      core/admin/departments#update
#                                           PUT    /admin/organizations/:organization_id/departments/:id(.:format)      core/admin/departments#update
#                                           DELETE /admin/organizations/:organization_id/departments/:id(.:format)      core/admin/departments#destroy
#                       admin_organizations GET    /admin/organizations(.:format)                                       core/admin/organizations#index
#                                           POST   /admin/organizations(.:format)                                       core/admin/organizations#create
#                    new_admin_organization GET    /admin/organizations/new(.:format)                                   core/admin/organizations#new
#                   edit_admin_organization GET    /admin/organizations/:id/edit(.:format)                              core/admin/organizations#edit
#                        admin_organization GET    /admin/organizations/:id(.:format)                                   core/admin/organizations#show
#                                           PATCH  /admin/organizations/:id(.:format)                                   core/admin/organizations#update
#                                           PUT    /admin/organizations/:id(.:format)                                   core/admin/organizations#update
#                                           DELETE /admin/organizations/:id(.:format)                                   core/admin/organizations#destroy
#               admin_direction_of_sciences GET    /admin/direction_of_sciences(.:format)                               core/admin/direction_of_sciences#index
#                                           POST   /admin/direction_of_sciences(.:format)                               core/admin/direction_of_sciences#create
#            new_admin_direction_of_science GET    /admin/direction_of_sciences/new(.:format)                           core/admin/direction_of_sciences#new
#           edit_admin_direction_of_science GET    /admin/direction_of_sciences/:id/edit(.:format)                      core/admin/direction_of_sciences#edit
#                admin_direction_of_science GET    /admin/direction_of_sciences/:id(.:format)                           core/admin/direction_of_sciences#show
#                                           PATCH  /admin/direction_of_sciences/:id(.:format)                           core/admin/direction_of_sciences#update
#                                           PUT    /admin/direction_of_sciences/:id(.:format)                           core/admin/direction_of_sciences#update
#                                           DELETE /admin/direction_of_sciences/:id(.:format)                           core/admin/direction_of_sciences#destroy
#               admin_critical_technologies GET    /admin/critical_technologies(.:format)                               core/admin/critical_technologies#index
#                                           POST   /admin/critical_technologies(.:format)                               core/admin/critical_technologies#create
#             new_admin_critical_technology GET    /admin/critical_technologies/new(.:format)                           core/admin/critical_technologies#new
#            edit_admin_critical_technology GET    /admin/critical_technologies/:id/edit(.:format)                      core/admin/critical_technologies#edit
#                 admin_critical_technology GET    /admin/critical_technologies/:id(.:format)                           core/admin/critical_technologies#show
#                                           PATCH  /admin/critical_technologies/:id(.:format)                           core/admin/critical_technologies#update
#                                           PUT    /admin/critical_technologies/:id(.:format)                           core/admin/critical_technologies#update
#                                           DELETE /admin/critical_technologies/:id(.:format)                           core/admin/critical_technologies#destroy
#                      admin_research_areas GET    /admin/research_areas(.:format)                                      core/admin/research_areas#index
#                                           POST   /admin/research_areas(.:format)                                      core/admin/research_areas#create
#                   new_admin_research_area GET    /admin/research_areas/new(.:format)                                  core/admin/research_areas#new
#                  edit_admin_research_area GET    /admin/research_areas/:id/edit(.:format)                             core/admin/research_areas#edit
#                       admin_research_area GET    /admin/research_areas/:id(.:format)                                  core/admin/research_areas#show
#                                           PATCH  /admin/research_areas/:id(.:format)                                  core/admin/research_areas#update
#                                           PUT    /admin/research_areas/:id(.:format)                                  core/admin/research_areas#update
#                                           DELETE /admin/research_areas/:id(.:format)                                  core/admin/research_areas#destroy
#                     approve_admin_request GET    /admin/requests/:id/approve(.:format)                                core/admin/requests#approve
#                      reject_admin_request GET    /admin/requests/:id/reject(.:format)                                 core/admin/requests#reject
#          activate_or_reject_admin_request PUT    /admin/requests/:id/activate_or_reject(.:format)                     core/admin/requests#activate_or_reject
#                            admin_requests GET    /admin/requests(.:format)                                            core/admin/requests#index
#                        edit_admin_request GET    /admin/requests/:id/edit(.:format)                                   core/admin/requests#edit
#                findsimilar_admin_request GET    /admin/requests/:id/findsimilar(.:format)                           core/admin/requests#findsimilar
#                             admin_request GET    /admin/requests/:id(.:format)                                        core/admin/requests#show
#                                           PATCH  /admin/requests/:id(.:format)                                        core/admin/requests#update
#                                           PUT    /admin/requests/:id(.:format)                                        core/admin/requests#update
#                         admin_quota_kinds GET    /admin/quota_kinds(.:format)                                         core/admin/quota_kinds#index
#                                           POST   /admin/quota_kinds(.:format)                                         core/admin/quota_kinds#create
#                      new_admin_quota_kind GET    /admin/quota_kinds/new(.:format)                                     core/admin/quota_kinds#new
#                     edit_admin_quota_kind GET    /admin/quota_kinds/:id/edit(.:format)                                core/admin/quota_kinds#edit
#                          admin_quota_kind PATCH  /admin/quota_kinds/:id(.:format)                                     core/admin/quota_kinds#update
#                                           PUT    /admin/quota_kinds/:id(.:format)                                     core/admin/quota_kinds#update
#                                           DELETE /admin/quota_kinds/:id(.:format)                                     core/admin/quota_kinds#destroy
#                            admin_clusters GET    /admin/clusters(.:format)                                            core/admin/clusters#index
#                                           POST   /admin/clusters(.:format)                                            core/admin/clusters#create
#                         new_admin_cluster GET    /admin/clusters/new(.:format)                                        core/admin/clusters#new
#                        edit_admin_cluster GET    /admin/clusters/:id/edit(.:format)                                   core/admin/clusters#edit
#                             admin_cluster GET    /admin/clusters/:id(.:format)                                        core/admin/clusters#show
#                                           PATCH  /admin/clusters/:id(.:format)                                        core/admin/clusters#update
#                                           PUT    /admin/clusters/:id(.:format)                                        core/admin/clusters#update
#                                           DELETE /admin/clusters/:id(.:format)                                        core/admin/clusters#destroy
#                        admin_cluster_logs GET    /admin/cluster_logs(.:format)                                        core/admin/cluster_logs#index
#                 owners_finder_admin_users GET    /admin/users/owners_finder(.:format)                                 core/admin/users#owners_finder
#    with_owned_projects_finder_admin_users GET    /admin/users/with_owned_projects_finder(.:format)                    core/admin/users#with_owned_projects_finder
#                          block_admin_user GET    /admin/users/:id/block(.:format)                                     core/admin/users#block
#                     reactivate_admin_user GET    /admin/users/:id/reactivate(.:format)                                core/admin/users#reactivate
#                               admin_users GET    /admin/users(.:format)                                               core/admin/users#index
#                     credential_deactivate PUT    /credentials/:credential_id/deactivate(.:format)                     core/credentials#deactivate
#                               credentials POST   /credentials(.:format)                                               core/credentials#create
#                            new_credential GET    /credentials/new(.:format)                                           core/credentials#new
#                               employments GET    /employments(.:format)                                               core/employments#index
#                                           POST   /employments(.:format)                                               core/employments#create
#                            new_employment GET    /employments/new(.:format)                                           core/employments#new
#                           edit_employment GET    /employments/:id/edit(.:format)                                      core/employments#edit
#                                employment GET    /employments/:id(.:format)                                           core/employments#show
#                                           PATCH  /employments/:id(.:format)                                           core/employments#update
#                                           PUT    /employments/:id(.:format)                                           core/employments#update
#                                           DELETE /employments/:id(.:format)                                           core/employments#destroy
#                            cancel_project GET    /projects/:id/cancel(.:format)                                       core/projects#cancel
#                           suspend_project GET    /projects/:id/suspend(.:format)                                      core/projects#suspend
#                        reactivate_project GET    /projects/:id/reactivate(.:format)                                   core/projects#reactivate
#                            finish_project GET    /projects/:id/finish(.:format)                                       core/projects#finish
#                         resurrect_project GET    /projects/:id/resurrect(.:format)                                    core/projects#resurrect
#                     invite_member_project POST   /projects/:id/invite_member(.:format)                                core/projects#invite_member
#             invite_users_from_csv_project POST   /projects/:id/invite_users_from_csv(.:format)                        core/projects#invite_users_from_csv
#                 delete_invitation_project DELETE /projects/:id/delete_invitation(.:format)                            core/projects#delete_invitation
#                resend_invitations_project POST   /projects/:id/resend_invitations(.:format)                           core/projects#resend_invitations
#                       drop_member_project PUT    /projects/:id/drop_member(.:format)                                  core/projects#drop_member
#                          project_sureties POST   /projects/:project_id/sureties(.:format)                             core/projects#sureties
#       toggle_member_access_state_projects PUT    /projects/toggle_member_access_state(.:format)                       core/projects#toggle_member_access_state
#                          project_requests POST   /projects/:project_id/requests(.:format)                             core/requests#create
#                       new_project_request GET    /projects/:project_id/requests/new(.:format)                         core/requests#new
#                           project_members POST   /projects/:project_id/members(.:format)                              core/members#create
#                       edit_project_member GET    /projects/:project_id/members/:id/edit(.:format)                     core/members#edit
#                            project_member PATCH  /projects/:project_id/members/:id(.:format)                          core/members#update
#                                           PUT    /projects/:project_id/members/:id(.:format)                          core/members#update
#                                  projects GET    /projects(.:format)                                                  core/projects#index
#                                           POST   /projects(.:format)                                                  core/projects#create
#                               new_project GET    /projects/new(.:format)                                              core/projects#new
#                              edit_project GET    /projects/:id/edit(.:format)                                         core/projects#edit
#                                   project GET    /projects/:id(.:format)                                              core/projects#show
#                                           PATCH  /projects/:id(.:format)                                              core/projects#update
#                                           PUT    /projects/:id(.:format)                                              core/projects#update
#                                           DELETE /projects/:id(.:format)                                              core/projects#destroy
#                            confirm_surety GET    /sureties/:id/confirm(.:format)                                      core/sureties#confirm
#                              close_surety GET    /sureties/:id/close(.:format)                                        core/sureties#close
#                                  sureties GET    /sureties(.:format)                                                  core/sureties#index
#                                           POST   /sureties(.:format)                                                  core/sureties#create
#                                new_surety GET    /sureties/new(.:format)                                              core/sureties#new
#                               edit_surety GET    /sureties/:id/edit(.:format)                                         core/sureties#edit
#                                    surety GET    /sureties/:id(.:format)                                              core/sureties#show
#                                           PATCH  /sureties/:id(.:format)                                              core/sureties#update
#                                           PUT    /sureties/:id(.:format)                                              core/sureties#update
#                                           DELETE /sureties/:id(.:format)                                              core/sureties#destroy
#                        organization_kinds GET    /organization_kinds(.:format)                                        core/organization_kinds#index
#     organization_organization_departments GET    /organizations/:organization_id/departments(.:format)                core/organization_departments#index
#                                           POST   /organizations/:organization_id/departments(.:format)                core/organization_departments#create
#  new_organization_organization_department GET    /organizations/:organization_id/departments/new(.:format)            core/organization_departments#new
#                             organizations GET    /organizations(.:format)                                             core/organizations#index
#                                           POST   /organizations(.:format)                                             core/organizations#create
#                          new_organization GET    /organizations/new(.:format)                                         core/organizations#new
#                         edit_organization GET    /organizations/:id/edit(.:format)                                    core/organizations#edit
#                              organization GET    /organizations/:id(.:format)                                         core/organizations#show
#                                           PATCH  /organizations/:id(.:format)                                         core/organizations#update
#                                           PUT    /organizations/:id(.:format)                                         core/organizations#update
#                            country_cities GET    /countries/:country_id/cities(.:format)                              core/cities#index
#                              country_city GET    /countries/:country_id/cities/:id(.:format)                          core/cities#show
#                                 countries GET    /countries(.:format)                                                 core/countries#index
#                  index_for_country_cities GET    /cities/index_for_country(.:format)                                  core/cities#index_for_country
#                             finder_cities GET    /cities/finder(.:format)                                             core/cities#finder
#                                    cities GET    /cities(.:format)                                                    core/cities#index
#                                           POST   /cities(.:format)                                                    core/cities#create
#                                  new_city GET    /cities/new(.:format)                                                core/cities#new
#                                 edit_city GET    /cities/:id/edit(.:format)                                           core/cities#edit
#                                      city GET    /cities/:id(.:format)                                                core/cities#show
#                                           PATCH  /cities/:id(.:format)                                                core/cities#update
#                                           PUT    /cities/:id(.:format)                                                core/cities#update
#                                           DELETE /cities/:id(.:format)                                                core/cities#destroy
#                                      root GET    /                                                                    core/projects#index
#
# Routes for Face::Engine:
#   root GET  /           face/home#show
#
# Routes for Authentication::Engine:
#      activate_user GET    /users/activate/:token(.:format) authentication/users#activate
# confirmation_users GET    /users/confirmation(.:format)    authentication/users#confirmation
#              users POST   /users(.:format)                 authentication/users#create
#           new_user GET    /users/new(.:format)             authentication/users#new
#        activations POST   /activations(.:format)           authentication/activations#create
#     new_activation GET    /activations/new(.:format)       authentication/activations#new
#            session POST   /session(.:format)               authentication/sessions#create
#        new_session GET    /session/new(.:format)           authentication/sessions#new
#                    DELETE /session(.:format)               authentication/sessions#destroy
#                    GET    /session(.:format)               authentication/sessions#destroy
#           password POST   /password(.:format)              authentication/passwords#create
#       new_password GET    /password/new(.:format)          authentication/passwords#new
#    change_password GET    /password/:token(.:format)       authentication/passwords#change
#               root GET    /                                authentication/sessions#new
#
# Routes for Pack::Engine:
#                  admin_root GET    /admin(.:format)                                        pack/admin/versions#index
#  manage_access_admin_access POST   /admin/accesses/:id/manage_access(.:format)             pack/admin/accesses#manage_access
#              admin_accesses GET    /admin/accesses(.:format)                               pack/admin/accesses#index
#                             POST   /admin/accesses(.:format)                               pack/admin/accesses#create
#            new_admin_access GET    /admin/accesses/new(.:format)                           pack/admin/accesses#new
#           edit_admin_access GET    /admin/accesses/:id/edit(.:format)                      pack/admin/accesses#edit
#                admin_access GET    /admin/accesses/:id(.:format)                           pack/admin/accesses#show
#                             PATCH  /admin/accesses/:id(.:format)                           pack/admin/accesses#update
#                             PUT    /admin/accesses/:id(.:format)                           pack/admin/accesses#update
#                             DELETE /admin/accesses/:id(.:format)                           pack/admin/accesses#destroy
#      admin_package_versions GET    /admin/packages/:package_id/versions(.:format)          pack/admin/versions#index
#                             POST   /admin/packages/:package_id/versions(.:format)          pack/admin/versions#create
#   new_admin_package_version GET    /admin/packages/:package_id/versions/new(.:format)      pack/admin/versions#new
#  edit_admin_package_version GET    /admin/packages/:package_id/versions/:id/edit(.:format) pack/admin/versions#edit
#       admin_package_version GET    /admin/packages/:package_id/versions/:id(.:format)      pack/admin/versions#show
#                             PATCH  /admin/packages/:package_id/versions/:id(.:format)      pack/admin/versions#update
#                             PUT    /admin/packages/:package_id/versions/:id(.:format)      pack/admin/versions#update
#                             DELETE /admin/packages/:package_id/versions/:id(.:format)      pack/admin/versions#destroy
#              admin_packages GET    /admin/packages(.:format)                               pack/admin/packages#index
#                             POST   /admin/packages(.:format)                               pack/admin/packages#create
#           new_admin_package GET    /admin/packages/new(.:format)                           pack/admin/packages#new
#          edit_admin_package GET    /admin/packages/:id/edit(.:format)                      pack/admin/packages#edit
#               admin_package GET    /admin/packages/:id(.:format)                           pack/admin/packages#show
#                             PATCH  /admin/packages/:id(.:format)                           pack/admin/packages#update
#                             PUT    /admin/packages/:id(.:format)                           pack/admin/packages#update
#                             DELETE /admin/packages/:id(.:format)                           pack/admin/packages#destroy
#              admin_versions GET    /admin/versions(.:format)                               pack/admin/versions#index
#                             POST   /admin/versions(.:format)                               pack/admin/versions#create
#           new_admin_version GET    /admin/versions/new(.:format)                           pack/admin/versions#new
#          edit_admin_version GET    /admin/versions/:id/edit(.:format)                      pack/admin/versions#edit
#               admin_version GET    /admin/versions/:id(.:format)                           pack/admin/versions#show
#                             PATCH  /admin/versions/:id(.:format)                           pack/admin/versions#update
#                             PUT    /admin/versions/:id(.:format)                           pack/admin/versions#update
#                             DELETE /admin/versions/:id(.:format)                           pack/admin/versions#destroy
#                             GET    /admin/accesses(.:format)                               pack/admin/accesses#index
#                             POST   /admin/accesses(.:format)                               pack/admin/accesses#create
#                             GET    /admin/accesses/new(.:format)                           pack/admin/accesses#new
#                             GET    /admin/accesses/:id/edit(.:format)                      pack/admin/accesses#edit
#                             GET    /admin/accesses/:id(.:format)                           pack/admin/accesses#show
#                             PATCH  /admin/accesses/:id(.:format)                           pack/admin/accesses#update
#                             PUT    /admin/accesses/:id(.:format)                           pack/admin/accesses#update
#                             DELETE /admin/accesses/:id(.:format)                           pack/admin/accesses#destroy
#    admin_options_categories GET    /admin/options_categories(.:format)                     pack/admin/options_categories#index
#                             POST   /admin/options_categories(.:format)                     pack/admin/options_categories#create
#  new_admin_options_category GET    /admin/options_categories/new(.:format)                 pack/admin/options_categories#new
# edit_admin_options_category GET    /admin/options_categories/:id/edit(.:format)            pack/admin/options_categories#edit
#      admin_options_category GET    /admin/options_categories/:id(.:format)                 pack/admin/options_categories#show
#                             PATCH  /admin/options_categories/:id(.:format)                 pack/admin/options_categories#update
#                             PUT    /admin/options_categories/:id(.:format)                 pack/admin/options_categories#update
#                             DELETE /admin/options_categories/:id(.:format)                 pack/admin/options_categories#destroy
#                        root GET    /                                                       pack/versions#index
#                             GET    /docs/:page(.:format)                                   pack/docs#show
#                    versions GET    /versions(.:format)                                     pack/versions#index
#                     version GET    /versions/:id(.:format)                                 pack/versions#show
#               json_packages GET    /packages/json(.:format)                                pack/packages#json
#            show_new_package GET    /packages/:id/show_new(.:format)                        pack/packages#show_new
#                    packages GET    /packages(.:format)                                     pack/packages#index
#                             POST   /packages(.:format)                                     pack/packages#create
#                 new_package GET    /packages/new(.:format)                                 pack/packages#new
#                edit_package GET    /packages/:id/edit(.:format)                            pack/packages#edit
#                     package GET    /packages/:id(.:format)                                 pack/packages#show
#                             PATCH  /packages/:id(.:format)                                 pack/packages#update
#                             PUT    /packages/:id(.:format)                                 pack/packages#update
#                             DELETE /packages/:id(.:format)                                 pack/packages#destroy
#               form_accesses GET    /accesses/form(.:format)                                pack/accesses#form
#                    accesses POST   /accesses/update(.:format)                              pack/accesses#update
#    update_accesses_accesses POST   /accesses/update_accesses(.:format)                     pack/accesses#update_accesses
#                             POST   /accesses/destroy(.:format)                             pack/accesses#destroy
#  load_for_versions_accesses GET    /accesses/load_for_versions(.:format)                   pack/accesses#load_for_versions
#       values_category_value GET    /category_values/:id/values(.:format)                   pack/category_values#values
#
# Routes for Announcements::Engine:
#           admin_announcement_deliver PUT    /admin/announcements/:announcement_id/deliver(.:format)           announcements/admin/announcements#deliver
#              admin_announcement_test PUT    /admin/announcements/:announcement_id/test(.:format)              announcements/admin/announcements#test
#        admin_announcement_show_users GET    /admin/announcements/:announcement_id/show_users(.:format)        announcements/admin/announcements#show_users
# admin_announcement_select_recipients POST   /admin/announcements/:announcement_id/select_recipients(.:format) announcements/admin/announcements#select_recipients
#                  admin_announcements GET    /admin/announcements(.:format)                                    announcements/admin/announcements#index
#                                      POST   /admin/announcements(.:format)                                    announcements/admin/announcements#create
#               new_admin_announcement GET    /admin/announcements/new(.:format)                                announcements/admin/announcements#new
#              edit_admin_announcement GET    /admin/announcements/:id/edit(.:format)                           announcements/admin/announcements#edit
#                   admin_announcement GET    /admin/announcements/:id(.:format)                                announcements/admin/announcements#show
#                                      PATCH  /admin/announcements/:id(.:format)                                announcements/admin/announcements#update
#                                      PUT    /admin/announcements/:id(.:format)                                announcements/admin/announcements#update
#                                      DELETE /admin/announcements/:id(.:format)                                announcements/admin/announcements#destroy
#                           admin_root GET    /admin(.:format)                                                  announcements/admin/announcements#index
#
# Routes for Comments::Engine:
#                         comments POST   /comments/update(.:format)                  comments/comments#update
#                                  POST   /comments/create(.:format)                  comments/comments#create
#                                  GET    /comments/index(.:format)                   comments/comments#index
#               index_all_comments GET    /comments/index_all(.:format)               comments/comments#index_all
#                          comment DELETE /comments/:id(.:format)                     comments/comments#destroy
#                             tags POST   /tags/update(.:format)                      comments/tags#update
#                                  POST   /tags/create(.:format)                      comments/tags#create
#                                  GET    /tags/index(.:format)                       comments/tags#index
#                   index_all_tags GET    /tags/index_all(.:format)                   comments/tags#index_all
#                              tag DELETE /tags/:id(.:format)                         comments/tags#destroy
#                tags_lookup_index GET    /tags_lookup(.:format)                      comments/tags_lookup#index
#                                  POST   /tags_lookup(.:format)                      comments/tags_lookup#create
#                  new_tags_lookup GET    /tags_lookup/new(.:format)                  comments/tags_lookup#new
#                 edit_tags_lookup GET    /tags_lookup/:id/edit(.:format)             comments/tags_lookup#edit
#                      tags_lookup GET    /tags_lookup/:id(.:format)                  comments/tags_lookup#show
#                                  PATCH  /tags_lookup/:id(.:format)                  comments/tags_lookup#update
#                                  PUT    /tags_lookup/:id(.:format)                  comments/tags_lookup#update
#                                  DELETE /tags_lookup/:id(.:format)                  comments/tags_lookup#destroy
#                            files POST   /files/update(.:format)                     comments/files#update
#                                  POST   /files/create(.:format)                     comments/files#create
#                                  GET    /files/index(.:format)                      comments/files#index
#                  index_all_files GET    /files/index_all(.:format)                  comments/files#index_all
#                             file DELETE /files/:id(.:format)                        comments/files#destroy
#                                  GET    /secured_uploads/:id/:file_name(.:format)   comments/files#show_file
#              admin_group_classes POST   /admin/group_classes/update(.:format)       comments/admin/group_classes#update
#         edit_admin_group_classes GET    /admin/group_classes/edit(.:format)         comments/admin/group_classes#edit
# list_objects_admin_group_classes GET    /admin/group_classes/list_objects(.:format) comments/admin/group_classes#list_objects
#     type_abs_admin_group_classes GET    /admin/group_classes/type_abs(.:format)     comments/admin/group_classes#type_abs
#             admin_context_groups POST   /admin/context_groups/update(.:format)      comments/admin/context_groups#update
#        edit_admin_context_groups GET    /admin/context_groups/edit(.:format)        comments/admin/context_groups#edit
#    type_abs_admin_context_groups GET    /admin/context_groups/type_abs(.:format)    comments/admin/context_groups#type_abs
#                   admin_contexts GET    /admin/contexts(.:format)                   comments/admin/contexts#index
#                                  POST   /admin/contexts(.:format)                   comments/admin/contexts#create
#                new_admin_context GET    /admin/contexts/new(.:format)               comments/admin/contexts#new
#               edit_admin_context GET    /admin/contexts/:id/edit(.:format)          comments/admin/contexts#edit
#                    admin_context PATCH  /admin/contexts/:id(.:format)               comments/admin/contexts#update
#                                  PUT    /admin/contexts/:id(.:format)               comments/admin/contexts#update
#                                  DELETE /admin/contexts/:id(.:format)               comments/admin/contexts#destroy
#
# Routes for Hardware::Engine:
#                  admin_root GET    /admin(.:format)                                hardware/admin/kinds#index
#          admin_items_states GET    /admin/items_states(.:format)                   hardware/admin/items_states#index
#                             POST   /admin/items_states(.:format)                   hardware/admin/items_states#create
#       new_admin_items_state GET    /admin/items_states/new(.:format)               hardware/admin/items_states#new
#      edit_admin_items_state GET    /admin/items_states/:id/edit(.:format)          hardware/admin/items_states#edit
#           admin_items_state GET    /admin/items_states/:id(.:format)               hardware/admin/items_states#show
#                             PATCH  /admin/items_states/:id(.:format)               hardware/admin/items_states#update
#                             PUT    /admin/items_states/:id(.:format)               hardware/admin/items_states#update
#                             DELETE /admin/items_states/:id(.:format)               hardware/admin/items_states#destroy
#          states_admin_kinds GET    /admin/kinds/states(.:format)                   hardware/admin/kinds#states
#      index_json_admin_kinds GET    /admin/kinds/index_json(.:format)               hardware/admin/kinds#index_json
#           admin_kind_states POST   /admin/kinds/:kind_id/states(.:format)          hardware/admin/states#create
#        new_admin_kind_state GET    /admin/kinds/:kind_id/states/new(.:format)      hardware/admin/states#new
#       edit_admin_kind_state GET    /admin/kinds/:kind_id/states/:id/edit(.:format) hardware/admin/states#edit
#            admin_kind_state GET    /admin/kinds/:kind_id/states/:id(.:format)      hardware/admin/states#show
#                             PATCH  /admin/kinds/:kind_id/states/:id(.:format)      hardware/admin/states#update
#                             PUT    /admin/kinds/:kind_id/states/:id(.:format)      hardware/admin/states#update
#                             DELETE /admin/kinds/:kind_id/states/:id(.:format)      hardware/admin/states#destroy
#                 admin_kinds GET    /admin/kinds(.:format)                          hardware/admin/kinds#index
#                             POST   /admin/kinds(.:format)                          hardware/admin/kinds#create
#              new_admin_kind GET    /admin/kinds/new(.:format)                      hardware/admin/kinds#new
#             edit_admin_kind GET    /admin/kinds/:id/edit(.:format)                 hardware/admin/kinds#edit
#                  admin_kind GET    /admin/kinds/:id(.:format)                      hardware/admin/kinds#show
#                             PATCH  /admin/kinds/:id(.:format)                      hardware/admin/kinds#update
#                             PUT    /admin/kinds/:id(.:format)                      hardware/admin/kinds#update
#                             DELETE /admin/kinds/:id(.:format)                      hardware/admin/kinds#destroy
# update_max_date_admin_items POST   /admin/items/update_max_date(.:format)          hardware/admin/items#update_max_date
#     json_update_admin_items POST   /admin/items/json_update(.:format)              hardware/admin/items#json_update
#      index_json_admin_items GET    /admin/items/index_json(.:format)               hardware/admin/items#index_json
#     admin_item_update_state POST   /admin/items/:item_id/update_state(.:format)    hardware/admin/items#update_state
#                 admin_items GET    /admin/items(.:format)                          hardware/admin/items#index
#                             POST   /admin/items(.:format)                          hardware/admin/items#create
#              new_admin_item GET    /admin/items/new(.:format)                      hardware/admin/items#new
#             edit_admin_item GET    /admin/items/:id/edit(.:format)                 hardware/admin/items#edit
#                  admin_item GET    /admin/items/:id(.:format)                      hardware/admin/items#show
#                             PATCH  /admin/items/:id(.:format)                      hardware/admin/items#update
#                             PUT    /admin/items/:id(.:format)                      hardware/admin/items#update
#                             DELETE /admin/items/:id(.:format)                      hardware/admin/items#destroy
#
# Routes for RailsDb::Engine:
#             root GET  /                                    rails_db/dashboard#index
#       table_data GET  /tables/:table_id/data(.:format)     rails_db/tables#data
#        table_csv GET  /tables/:table_id/csv(.:format)      rails_db/tables#csv
#   table_truncate GET  /tables/:table_id/truncate(.:format) rails_db/tables#truncate
#    table_destroy GET  /tables/:table_id/destroy(.:format)  rails_db/tables#destroy
#       table_edit GET  /tables/:table_id/edit(.:format)     rails_db/tables#edit
#     table_update PUT  /tables/:table_id/update(.:format)   rails_db/tables#update
#       table_xlsx GET  /tables/:table_id/xlsx(.:format)     rails_db/tables#xlsx
#        table_new GET  /tables/:table_id/new(.:format)      rails_db/tables#new
#     table_create POST /tables/:table_id/create(.:format)   rails_db/tables#create
#           tables GET  /tables(.:format)                    rails_db/tables#index
#            table GET  /tables/:id(.:format)                rails_db/tables#show
#              sql GET  /sql(.:format)                       rails_db/sql#index
#       sql_import GET  /import(.:format)                    rails_db/sql#import
#      sql_execute POST /execute(.:format)                   rails_db/sql#execute
#          sql_csv POST /sql-csv(.:format)                   rails_db/sql#csv
#          sql_xls POST /sql-xls(.:format)                   rails_db/sql#xls
# sql_start_import POST /import-start(.:format)              rails_db/sql#import_start
#       data_table GET  /data-table(.:format)                rails_db/dashboard#data_table
#       standalone GET  /standalone(.:format)                rails_db/dashboard#standalone

require "sidekiq/web"
require "admin_constraint"

Octoshell::Application.routes.draw do

  mount RailsEmailPreview::Engine, at: '/admin/emails'


  # This line mounts Api routes at /api by default.

  # This line mounts Wikiplus routes at /wikiplus by default.
  # mount Wikiplus::Engine, :at => "/wikiplus"

  # This line mounts Wiki routes at /wiki by default.
  #mount Wiki::Engine, :at => "/wiki"

  # This line mounts Wiki routes at /wiki by default.
  # mount Wiki::Engine, :at => "/wiki"
  # This line mounts Jobstat routes at /jobstat by default.
  # mount Jobstat::Engine, at: "/jobstat"

  # This line mounts Statistics routes at /stats by default.
  # mount Statistics::Engine, :at => "/admin/stats"

  # This line mounts Sessions's routes at /sessions by default.
  # mount Sessions::Engine, :at => "/sessions"

  # This line mounts Support's routes at /support by default.
  # mount Support::Engine, :at => "/support"

  # This line mounts Core's routes at /core by default.
  # mount Core::Engine, :at => "/core"

  # This line mounts Face's routes at / by default.
  # mount Face::Engine, at: "/"

  # This line mounts Authentication's routes at /auth by default.
  mount Authentication::Engine, at: "/auth"

  # mount Pack::Engine, at: "/pack"
  # mount Announcements::Engine, :at => "/announcements"

  Octoface::OctoConfig.instances.values.each do |instance|
    instance_eval &instance.routes_block if instance.routes_block
  end
  # mount Hardware::Engine, at: "/hardware"
  # mount Reports::Engine, at: "/reports"


  root "face/home#show"

  # Journal
  resources :users do
    get :login_as, on: :member
    get :return_to_self, on: :member
  end

  resources :lang_prefs, only: {} do
    collection do
      post :change
    end
  end

  resource :profile

  resources :options, only: [] do
    collection do
      get :categories
    end

    member do
      get :values
    end

  end


  namespace :admin do
    mount Sidekiq::Web => "/sidekiq", :constraints => AdminConstraint.new
    get 'journal' => 'journal#journal'
    # get "journal" => "journal#journal"

    resources :users do
      member do
        post :block_access
        post :unblock_access
      end
      collection do
        get :id_finder
      end
    end

    resources :groups do
      put :default, on: :collection
    end

    resources :options_categories do

    end
    mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  end
  get '*path.:ext', to: 'catch_all#index', xhr: true
end

# require "#{Rails.root}/engines/core/config/routes.rb"

# Dir.entries("#{Rails.root}/engines").select { |path| path.first != '.' }.map do |engine|
#   puts engine.red
#   require "#{Rails.root}/engines/#{engine}/config/routes.rb"
# end
# puts Octoface::OctoConfig.instances.map(&:mod).map{ |mod| eval("#{mod}::Engine").root.to_s }.inspect.red
# ActiveSupport.on_load(:i18n) do
#   puts 'init'.red
#   # Face::MyMenu.validate_keys!
# end
