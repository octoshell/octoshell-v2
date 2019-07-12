module JournalHelper

    def get_if_bold(id)
        if(params[:chain])
            if(id == params[:chain]["id"].to_i)
                return "bold"
            end
        end

        return ""
    end

    def get_chain_color(id)
        result = 0
        color = "#000000"

        if(@chains_count == 5)
            return color
        end

        @chains.each_key do |key|
            if(@chains[key].include? id)
                result = key.to_i
            end
        end

        if(not @used_chains.include? result)
            @used_chains += [result]
            @chains_count += 1
        end

        result = @used_chains.find_index(result) + 1

        if(result == 1)
            color = "#00008b"
        elsif(result == 2)
            color = "#8a2be2"
        elsif(result == 3)
            color = "#9acd32"
        elsif(result == 4)
            color = "#ff00ff"
        elsif(result == 5)
            color = "#a52a2a"
        end

        return color
    end
end
