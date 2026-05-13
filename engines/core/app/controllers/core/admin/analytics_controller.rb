module Core
  class Admin::AnalyticsController < Admin::ApplicationController
    # skip_before_action :authorize_admins, only: [:index, :sinfo, :create_comment], raise: false
    before_action :require_analytics_access
    before_action :octo_authorize!
    octo_use(:project_class, :core, 'Project')
    EFFECTIVE_STATE_PRIORITY = {
      'down' => 100,
      'drain' => 90,
      'drng' => 80,
      'maint' => 70,
      'reserved' => 60,
      'alloc' => 50,
      'mix' => 40,
      'comp' => 30,
      'idle' => 10
    }.freeze

    # before_action :prepare_comments, only: [:index, :create_comment, :sinfo]
    before_action :prepare_comments, only: %i[index create_comment]

    def index
      @total_reports     = 0
      @submitted_reports = 0
      @assessing_reports = 0
      @rejected_reports  = 0

      @clusters = Core::Cluster.order(:name_ru).includes(:nodes)

      node_states_rel = Core::NodeState.current
      @global_state_counts = grouped_effective_node_state_counts(node_states_rel)

      # pp @global_state_counts
      # dwadwawda
      @cluster_stats = {}
      @clusters.each do |cluster|
        @cluster_stats[cluster.id] = {
          total_nodes: cluster.nodes.size,
          states: Hash.new(0),
          issues: 0
        }
      end

      # временно отключено из-за ошибки column "cluster_id" does not exist
      states_counts = grouped_effective_node_state_counts(node_states_rel, :cluster_id)
      states_counts.each do |(cluster_id, state), count|
        next unless @cluster_stats.key?(cluster_id)

        @cluster_stats[cluster_id][:states][state] = count
      end
      issues_counts = grouped_distinct_node_counts(
        node_states_rel.where.not(reason: [nil, '']).where.not('LOWER(reason) = ?', 'none').joins(:node),
        'core_nodes.cluster_id'
      )
      issues_counts.each do |cluster_id, count|
        next unless @cluster_stats.key?(cluster_id)

        @cluster_stats[cluster_id][:issues] = count
      end

      @partition_stats = {}
      partition_counts = grouped_distinct_node_counts(
        node_states_rel.joins(node: { node_partitions: :partition }),
        'core_partitions.cluster_id',
        'core_partitions.id',
        'core_partitions.name',
        'core_node_states.state'
      )

      partition_counts.each do |(cluster_id, partition_id, partition_name, state), count|
        @partition_stats[cluster_id] ||= {}
        @partition_stats[cluster_id][partition_id] ||= {
          name: partition_name,
          states: Hash.new(0)
        }
        @partition_stats[cluster_id][partition_id][:states][state] = count
      end

      @latest_snapshots = Core::Snapshot.latest_first.includes(:cluster).limit(10)
      @snapshot_stats   = {}

      if @latest_snapshots.any?
        @latest_snapshots.each do |snapshot|
          @snapshot_stats[snapshot.id] = effective_state_counts_at(
            snapshot.cluster_id,
            snapshot.captured_at
          )
        end
      end
      pp @snapshot_stats
      @active_tab ||= 'analytics'
    end

    def availability
      @clusters = Core::Cluster.order(:name_ru).includes(:nodes)

      @from   = parse_time(params[:from]) || 7.days.ago
      @to     = parse_time(params[:to])   || Time.current
      @metric = params[:metric].presence || 'idle' # idle | work | up

      @active_tab = 'availability'
    end

    def availability_data
      cluster = Core::Cluster.find(params[:cluster_id])

      from   = parse_time(params[:from]) || 7.days.ago
      to     = parse_time(params[:to])   || Time.current
      metric = params[:metric].presence || 'idle'

      total_nodes = Core::Node.where(cluster_id: cluster.id).distinct.count(:id)

      snaps = cluster.snapshots
                     .where(captured_at: from..to)
                     .order(:captured_at)
                     .limit(2000)

      comments = cluster.comments
                        .where('valid_from <= ? AND (valid_to IS NULL OR valid_to >= ?)', to, from)
                        .order(:valid_from)
                        .limit(500)
                        .map do |c|
                          {
                            from: c.valid_from.iso8601,
                            to: (c.valid_to || to).iso8601,
                            severity: c.severity.to_s,
                            title: c.title.to_s,
                            nodes_count: c.nodes.size
                          }
                        end

      aggregate = build_state_aggregate_data(
        from: from,
        to: to,
        cluster_id: cluster.id,
        total_nodes: total_nodes
      )

      pie = aggregate[:pie]
      availability_summary = aggregate[:availability_summary]

      if snaps.blank?
        return render json: {
          cluster_id: cluster.id,
          total_nodes: total_nodes,
          metric: metric,
          from: from.iso8601,
          to: to.iso8601,
          states: [],
          series: {},
          points: [],
          comments: comments,
          pie: pie,
          availability_summary: availability_summary
        }
      end

      snap_effective_counts = {}

      snaps.each do |snap|
        snap_effective_counts[snap.id] = effective_state_counts_at(
          cluster.id,
          snap.captured_at
        )
      end

      states =
        (
          Core::NodeState::STATES.map(&:to_s) +
          snap_effective_counts.values.flat_map(&:keys)
        ).uniq

      unavailable_states = availability_unavailable_states

      if metric != 'states'
        points = snaps.map do |snap|
          cur = Hash.new(0)
          snap_effective_counts[snap.id].each do |state, count|
            cur[state] = count.to_i
          end

          idle  = cur['idle'].to_i
          alloc = cur['alloc'].to_i

          y =
            case metric
            when 'work'
              alloc + idle
            when 'up'
              available_nodes_count(total_nodes, cur, unavailable_states)
            else
              idle
            end

          { x: snap.captured_at.iso8601, y: y }
        end

        return render json: {
          cluster_id: cluster.id,
          total_nodes: total_nodes,
          metric: metric,
          from: from.iso8601,
          to: to.iso8601,
          points: points,
          comments: comments,
          pie: pie,
          availability_summary: availability_summary
        }
      end

      series = Hash.new { |h, k| h[k] = [] }

      snaps.each do |snap|
        cur = Hash.new(0)
        snap_effective_counts[snap.id].each do |state, count|
          cur[state] = count.to_i
        end

        x = snap.captured_at.iso8601

        states.each do |state|
          series[state] << { x: x, y: cur[state].to_i }
        end

        available_y = available_nodes_count(total_nodes, cur, unavailable_states)
        series['available'] << { x: x, y: available_y }
      end

      states.select! do |state|
        series[state].any? { |point| point[:y].to_i > 0 }
      end

      states << 'available' if series['available'].any? { |point| point[:y].to_i > 0 }

      states.uniq!
      series.slice!(*states)

      render json: {
        cluster_id: cluster.id,
        total_nodes: total_nodes,
        metric: metric,
        from: from.iso8601,
        to: to.iso8601,
        states: states,
        series: series,
        comments: comments,
        pie: pie,
        availability_summary: availability_summary
      }
    end

    # Обновление состояния узлов через вызов Core::Cluster#log_node_states
    def sinfo
      Rails.logger.info("[SINFO] start cluster_id=#{params[:cluster_id]} user_id=#{current_user&.id}")

      cluster = Core::Cluster.find_by(id: params[:cluster_id])
      unless cluster
        flash[:alert] = 'Кластер не найден.'
        redirect_to url_for(controller: '/core/admin/analytics', action: :index)
        return
      end

      begin
        cluster.log_node_states
        flash[:notice] = 'Состояние узлов успешно обновлено.'
      rescue StandardError => e
        Rails.logger.error("[SINFO] error #{e.class}: #{e.message}")
        flash[:alert] = "Ошибка обновления состояния узлов: #{e.message}"
      end

      redirect_to url_for(controller: '/core/admin/analytics', action: :index, cluster_id: cluster.id)
    end

    def create_comment
      if request.get?
        index
        @active_tab = 'comments'
        render :index
        return
      end

      @comment = Core::Comments::Comment.new(comment_params)
      @comment.author = current_user

      if @comment.save
        flash[:notice] = 'Комментарий сохранён.'
        redirect_to url_for(controller: '/core/admin/analytics', action: :index, tab: 'comments',
                            cluster_id: @comment.cluster_id)
      else
        flash.now[:alert] = 'Не удалось сохранить комментарий.'
        index
        @active_tab = 'comments'
        render :index
      end
    end

    def create_tag
      label = params.dig(:tag, :label).to_s.strip
      return render_tags_update(alert: 'Введите название тега.', status: 422) if label.blank?

      group = Core::Comments::TagGroup.find_or_create_by!(key: 'custom') do |g|
        g.name = 'Пользовательские'
        g.sort_order = 1000
        g.is_active = true
      end

      base_key = label.parameterize(separator: '_')
      base_key = "tag_#{SecureRandom.hex(4)}" if base_key.blank?

      key = base_key
      i = 2
      while Core::Comments::Tag.exists?(group_id: group.id, key: key)
        key = "#{base_key}_#{i}"
        i += 1
      end

      tag = Core::Comments::Tag.new(
        group_id: group.id,
        key: key,
        label: label,
        sort_order: 0,
        is_active: true
      )

      if tag.save
        render_tags_update(notice: 'Тег добавлен.', auto_check_tag_id: tag.id)
      else
        render_tags_update(alert: tag.errors.full_messages.to_sentence, status: 422)
      end
    end

    def destroy_tag
      tag = Core::Comments::Tag.find(params[:id])

      if tag.group&.key != 'custom'
        return render_tags_update(alert: 'Удалять можно только пользовательские теги (custom).', status: 422)
      end

      tag.destroy
      render_tags_update(notice: 'Тег удалён.')
    end

    private

    def parse_time(str)
      return nil if str.blank?

      Time.zone.parse(str.to_s)
    rescue StandardError
      nil
    end

    def grouped_distinct_node_counts(relation, *group_columns)
      rel = relation.where.not(node_id: nil)

      return rel.distinct.count(:node_id) if group_columns.blank?

      rel.group(*group_columns).distinct.count(:node_id)
    end

    def grouped_effective_node_state_counts(relation, *group_columns)
      group_columns = group_columns.map(&:to_sym)

      # Если нужно группировать по cluster_id, добавляем join с узлом и выбираем cluster_id как алиас
      if group_columns.include?(:cluster_id)
        relation = relation.joins(:node).select('core_nodes.cluster_id as cluster_id')
        # selected_columns остаются символами, потому что алиас cluster_id теперь присутствует в результате
        selected_columns = group_columns + %i[node_id state]
      else
        selected_columns = group_columns + %i[node_id state]
      end

      best_state_by_node = {}

      relation
        .where.not(node_id: nil)
        .pluck(*selected_columns)
        .each do |row|
          group_values = row.first(group_columns.length)
          node_id = row[group_columns.length]
          raw_state = row[group_columns.length + 1].to_s
          # Remove SLURM suffixes (~, #, *) for consistent grouping
          base_state = raw_state.gsub(/[~#*]$/, '')
          priority = EFFECTIVE_STATE_PRIORITY.fetch(base_state, 0)

          node_key = group_values + [node_id]
          current = best_state_by_node[node_key]

          next unless current.nil? || priority > current[:priority]

          best_state_by_node[node_key] = {
            group_values: group_values,
            state: base_state,
            priority: priority
          }
        end

      counts = Hash.new(0)

      best_state_by_node.each_value do |item|
        key_values = item[:group_values] + [item[:state]]
        key = key_values.one? ? key_values.first : key_values
        counts[key] += 1
      end

      counts
    end

    def effective_state_counts_at(cluster_id, time)
      grouped_effective_node_state_counts(
        Core::NodeState.at(time).joins(:node).where(core_nodes: { cluster_id: cluster_id })
      ).transform_keys(&:to_s)
    end

    def availability_unavailable_states
      %w[down drain drng maint reserved]
    end

    def available_nodes_count(total_nodes, counts, unavailable_states = availability_unavailable_states)
      total = total_nodes.to_i
      total = counts.values.sum(&:to_i) if total <= 0

      unavailable = unavailable_states.sum { |state| counts[state].to_i }

      [[total - unavailable, 0].max, total].min
    end

    def build_state_aggregate_data(from:, to:, cluster_id:, total_nodes:)
      empty_pie = {
        items: [],
        total_seconds: 0.0,
        total_node_hours: 0.0
      }

      empty_summary = {
        total_nodes: total_nodes.to_i,
        unavailable_states: availability_unavailable_states,
        max_available: 0,
        max_available_percent: 0.0,
        avg_available: 0.0,
        avg_available_percent: 0.0,
        max_intervals: []
      }

      return { pie: empty_pie, availability_summary: empty_summary } if to <= from

      base_counts =
        grouped_distinct_node_counts(
          Core::NodeState.at(from).joins(:node).where(core_nodes: { cluster_id: cluster_id }),
          :state
        ).transform_keys(&:to_s)

      total_nodes = total_nodes.to_i
      total_nodes = base_counts.values.sum(&:to_i) if total_nodes <= 0

      enter_raw =
        grouped_distinct_node_counts(
          Core::NodeState
            .joins(:node).where(core_nodes: { cluster_id: cluster_id })
            .where(
              snapshot_id: Core::Snapshot
                .where(cluster_id: cluster_id, captured_at: from..to)
                .select(:id)
            ),
          :snapshot_id,
          :state
        )

      snaps_by_id =
        Core::Snapshot
        .where(cluster_id: cluster_id, captured_at: from..to)
        .pluck(:id, :captured_at)
        .to_h

      enter_by_time = Hash.new { |h, k| h[k] = Hash.new(0) }
      enter_raw.each do |(snapshot_id, state), count|
        captured_at = snaps_by_id[snapshot_id]
        next unless captured_at

        enter_by_time[captured_at][state.to_s] += count.to_i
      end

      # leave_raw - поле valid_to отсутствует в новой модели, временно игнорируем
      leave_raw = {}
      leave_by_time = Hash.new { |h, k| h[k] = Hash.new(0) }

      states =
        (
          Core::NodeState::STATES.map(&:to_s) +
          base_counts.keys +
          enter_raw.keys.map { |(_, st)| st.to_s } +
          leave_raw.keys.map { |(_, st)| st.to_s }
        ).uniq

      cur = Hash.new(0)
      base_counts.each { |state, count| cur[state] = count.to_i }

      state_seconds = Hash.new(0.0)

      unavailable_states = availability_unavailable_states

      available_weighted_seconds = 0.0
      total_duration_seconds = 0.0

      max_available = nil
      max_intervals = []

      change_times = (enter_by_time.keys + leave_by_time.keys + [to])
                     .select { |t| t.present? && t > from && t <= to }
                     .uniq
                     .sort

      prev_time = from

      change_times.each do |time_point|
        duration = time_point - prev_time

        if duration.positive?
          states.each do |state|
            count = cur[state].to_i
            next if count <= 0

            state_seconds[state] += count * duration
          end

          available = available_nodes_count(total_nodes, cur, unavailable_states)

          available_weighted_seconds += available * duration
          total_duration_seconds += duration

          if max_available.nil? || available > max_available
            max_available = available
            max_intervals = [{ from: prev_time, to: time_point }]
          elsif available == max_available
            if max_intervals.last && max_intervals.last[:to] == prev_time
              max_intervals.last[:to] = time_point
            else
              max_intervals << { from: prev_time, to: time_point }
            end
          end
        end

        leave_by_time[time_point].each do |state, count|
          cur[state] -= count.to_i
        end

        enter_by_time[time_point].each do |state, count|
          cur[state] += count.to_i
        end

        prev_time = time_point
      end

      total_seconds = state_seconds.values.sum

      items = states.filter_map do |state|
        seconds = state_seconds[state].to_f
        next if seconds <= 0

        {
          state: state,
          seconds: seconds.round(2),
          node_hours: (seconds / 3600.0).round(2),
          percent: total_seconds.positive? ? ((seconds / total_seconds) * 100.0).round(2) : 0.0
        }
      end

      avg_available =
        if total_duration_seconds.positive?
          available_weighted_seconds / total_duration_seconds
        else
          0.0
        end

      max_available ||= 0

      availability_summary = {
        total_nodes: total_nodes,
        unavailable_states: unavailable_states,
        max_available: max_available,
        max_available_percent: total_nodes.positive? ? ((max_available.to_f / total_nodes) * 100.0).round(2) : 0.0,
        avg_available: avg_available.round(2),
        avg_available_percent: total_nodes.positive? ? ((avg_available / total_nodes) * 100.0).round(2) : 0.0,
        max_intervals: max_intervals.map do |interval|
          {
            from: interval[:from].iso8601,
            to: interval[:to].iso8601,
            duration_seconds: (interval[:to] - interval[:from]).round(2)
          }
        end
      }

      pie = {
        items: items,
        total_seconds: total_seconds.round(2),
        total_node_hours: (total_seconds / 3600.0).round(2)
      }

      {
        pie: pie,
        availability_summary: availability_summary
      }
    end

    def comment_params
      key =
        if params[:comment].present?
          :comment
        elsif params[:comments_comment].present?
          :comments_comment
        else
          raise ActionController::ParameterMissing, :comment
        end

      permitted = params.require(key).permit(
        :cluster_id,
        :title,
        :body,
        :valid_from,
        :valid_to,
        :severity,
        :reason_group_id,
        :reason_id,
        node_ids: []
      )

      permitted[:node_ids] = Array(permitted[:node_ids]).reject(&:blank?).map(&:to_i).uniq
      permitted[:reason_group_id] = permitted[:reason_group_id].presence&.to_i
      permitted[:reason_id] = permitted[:reason_id].presence&.to_i

      permitted
    end

    def role?(name)
      return false unless current_user

      sym  = name.to_sym
      pred = "#{sym}?".to_sym
      if current_user.respond_to?(pred)
        current_user.public_send(pred)
      elsif current_user.respond_to?(:has_role?)
        current_user.has_role?(sym)
      else
        false
      end
    end

    def can_read_reports?
      return false unless respond_to?(:can?)

      can?(:read, :reports) || can?(:manage, :reports)
    rescue StandardError
      false
    end

    def require_analytics_access
      allowed = role?(:superadmin) ||
                role?(:reregistrator) ||
                role?(:admin) ||
                role?(:expert) ||
                can_read_reports?

      redirect_to main_app.admin_users_path, alert: 'Нет доступа к аналитике' unless allowed
    end

    def prepare_comments
      @comment ||= Core::Comments::Comment.new(valid_from: Time.current)

      @nodes = Core::Node
               .select(:id, :cluster_id, :name, "' ' as prefix")
               .order(:cluster_id, :prefix, :name)

      rel = Core::Comments::Comment
            .includes(:author, :cluster, :nodes)
            .recent_first

      rel = rel.where(cluster_id: params[:cluster_id]) if params[:cluster_id].present?
      rel = rel.where(severity: params[:severity]) if params[:severity].present?
      rel = rel.current if params[:active_only].to_s == '1'

      @recent_comments = rel.limit(20)
    end

    def custom_tag_labels_from_params
      raw = params.dig(:comment, :new_tags) || params.dig(:comments_comment, :new_tags)
      return [] if raw.blank?

      raw.to_s
         .split(/[,\n;]/)
         .map(&:strip)
         .reject(&:blank?)
         .uniq
         .take(10)
    end

    def ensure_custom_tags(labels)
      return [] if labels.blank?

      group = Core::Comments::TagGroup.find_or_create_by!(key: 'custom') do |g|
        g.name = 'Пользовательские'
        g.sort_order = 1000
        g.is_active = true
      end

      labels.map { |label| find_or_create_tag_in_group(group, label).id }
    end

    def find_or_create_tag_in_group(group, label)
      existing = Core::Comments::Tag.where(group_id: group.id)
                                    .where('LOWER(label) = ?', label.downcase)
                                    .first
      return existing if existing

      base_key = label.to_s.parameterize(separator: '_')
      base_key = "tag_#{SecureRandom.hex(4)}" if base_key.blank?

      key = base_key
      i = 2
      while Core::Comments::Tag.exists?(group_id: group.id, key: key)
        key = "#{base_key}_#{i}"
        i += 1
      end

      Core::Comments::Tag.create!(
        group_id: group.id,
        key: key,
        label: label,
        sort_order: 0,
        is_active: true
      )
    end

    def load_tags_data
      @tag_groups = Core::Comments::TagGroup.includes(:tags).order(:sort_order, :id)
      @tag_usage  = Core::Comments::CommentTag.group(:tag_id).count
    end

    def render_tags_update(notice: nil, alert: nil, auto_check_tag_id: nil, status: 200)
      load_tags_data

      checkboxes_html = render_to_string(
        partial: 'core/admin/analytics/tags_checkboxes',
        formats: [:html],
        locals: { tag_groups: @tag_groups, comment: @comment || Core::Comments::Comment.new }
      )

      manage_html = render_to_string(
        partial: 'core/admin/analytics/tags_manage',
        formats: [:html],
        locals: { tag_groups: @tag_groups, tag_usage: @tag_usage }
      )

      js = <<~JS
        (function(){
          var checked = Array.prototype.slice.call(
            document.querySelectorAll('#tag_checkboxes_container input[type="checkbox"]:checked')
          ).map(function(cb){ return cb.value; });

          var c = document.getElementById('tag_checkboxes_container');
          var m = document.getElementById('tag_manage_container');

          if (c) { c.innerHTML = #{checkboxes_html.to_json}; }
          if (m) { m.innerHTML = #{manage_html.to_json}; }

          checked.forEach(function(id){
            var cb = document.querySelector('#tag_checkboxes_container input[type="checkbox"][value="'+id+'"]');
            if (cb) cb.checked = true;
          });

          #{auto_check_tag_id ? "var cb2=document.querySelector('#tag_checkboxes_container input[type=\"checkbox\"][value=\"#{auto_check_tag_id}\"]'); if(cb2) cb2.checked=true;" : ''}

          var n=document.getElementById('tags_notice');
          if(n){
            n.textContent = #{(notice || '').to_json};
            n.style.display = #{notice ? "'block'" : "'none'"};
          }
          var a=document.getElementById('tags_alert');
          if(a){
            a.textContent = #{(alert || '').to_json};
            a.style.display = #{alert ? "'block'" : "'none'"};
          }
        })();
      JS

      render js: js, status: status
    end
  end
end
