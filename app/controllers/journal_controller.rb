class JournalController < ApplicationController

    def date_format
        "%Y-%m-%d"
    end

    def journal
        @item_types = PaperTrail::Version.uniq.order("item_type").pluck(:item_type).map { |x| [x, x] }
        @events = PaperTrail::Version.uniq.order("event").pluck(:event).map { |x| [x, x] }
        @user_groups = [[2, 'Администраторы'], [3, 'Пользователи'], [4, 'Система']]
        @emails = User.pluck(:email).map { |x| [x, x] } + [["Система", "Система"]]

        @used_chains = []
        @chains_count = 0
        @chains = find_chains

        @lastmonth = (DateTime.now - 1.month).strftime(date_format)
        @lastweek = (DateTime.now - 7.day).strftime(date_format)
        @today = DateTime.now.strftime(date_format)

        @time_from_date = (filter_params["time_from_date"] ? filter_params["time_from_date"] : @lastweek)
        @time_from_hours = (filter_params["time_from_hours"] ? filter_params["time_from_hours"] : "00:00")

        @time_to_date = (filter_params["time_to_date"] ? filter_params["time_to_date"] : @today)
        @time_to_hours = (filter_params["time_to_hours"] ? filter_params["time_to_hours"] : "23:59")

        if(params[:chain])
            @table = show_chain
        else
            @table = filter(PaperTrail::Version.all.order('id DESC'))
        end
    end

    private def filter_params
        params.permit!
        params.fetch(:filter, {}).clone
    end

    private def filter(relation)
        return relation unless filter_params.any?
        whodunnit = []
        system_flag = false

        # Clear all empty fields.
        new_filter_params = filter_params.delete_if {|k, v| v == "" or v == [""]}
        
        # Change email to id.
        if(new_filter_params["whodunnit"])
            if(new_filter_params["whodunnit"].include? "Система")
                system_flag = true
            end
            whodunnit = User.where(email: new_filter_params["whodunnit"]).ids
        else
            whodunnit = User.all.ids
            system_flag = true
        end

        # Find changes.
        if(new_filter_params["object_changes"])
            object_changes = new_filter_params["object_changes"]
            object_changes = PaperTrail::Version.all.where("object_changes LIKE (?)", "%#{object_changes}%").ids
        else
            object_changes = PaperTrail::Version.all.ids
        end

        # Get times and group_id, and remove them.
        time_from_date = new_filter_params["time_from_date"] ? new_filter_params["time_from_date"] : @lastweek
        time_from_hours = new_filter_params["time_from_hours"] ? new_filter_params["time_from_hours"] : "00:00"

        time_to_date = new_filter_params["time_to_date"] ? new_filter_params["time_to_date"] : @today
        time_to_hours = new_filter_params["time_to_hours"] ? new_filter_params["time_to_hours"] : "23:59"

        group_id = new_filter_params["group_id"]

        new_filter_params = new_filter_params.except("time_from_date", "time_from_hours", "time_to_date", "time_to_hours", "group_id", "whodunnit", "object_changes")

        # Convert times.
        time_from = DateTime.strptime(time_from_date + " " + time_from_hours + " +3", date_format + " %H:%M %z")
        time_to = DateTime.strptime(time_to_date + " " + time_to_hours + " +3", date_format + " %H:%M %z")

        # Filter table.
        without_id_results = relation.where(new_filter_params).where(created_at: time_from...time_to).where(id: object_changes)
        tmp_results = without_id_results.where(whodunnit: whodunnit)
        if(system_flag)
            tmp_results += without_id_results.where(whodunnit: nil)
        end

        results = []

        # Return search results.
        if(group_id == nil)
            results = tmp_results
        elsif
            if(group_id.include? "2")
                results += tmp_results.where(whodunnit: User.superadmins.ids)
            end

            if(group_id.include? "3")
                results += tmp_results.where(whodunnit: User.all.ids - User.superadmins.ids)
            end

            if(group_id.include? "4")
                results += tmp_results.where(whodunnit: nil)
            end
        end

        results
    end

    private def show_chain
        id = params[:chain]["id"].to_i
        result = []

        @chains.each_key do |key|
            if(@chains[key].include? id)
                result = @chains[key]
                break
            end
        end

        PaperTrail::Version.where(id: result).order("id DESC")
    end

    private def find_chains
        chains = {}
        chain_id = 1

        users = PaperTrail::Version.uniq.pluck("whodunnit")

        users.each do |user|
            user_rows = PaperTrail::Version.where(whodunnit: user)
            sessions = user_rows.uniq.pluck("session_id")

            sessions.each do |session|
                rows = user_rows.where(session_id: session).order("created_at DESC")
                time = rows.first.created_at

                chain = []
                rows.each do |r|
                    if((time - r.created_at).second <= 1.second)
                        chain += [r.id]
                        time = r.created_at
                    else
                        chains[chain_id] = chain
                        chain_id += 1

                        chain = [r.id]
                        time = r.created_at
                    end
                end

                chains[chain_id] = chain
                chain_id += 1
            end
        end

        chains
    end
end
