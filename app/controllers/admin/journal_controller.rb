class Admin::JournalController < Admin::ApplicationController
  before_action :authorize_admins!
  before_action do
    raise CanCan::AccessDenied if User.superadmins.exclude? current_user
  end

  def journal
    @search = PaperTrail::Version.ransack(params[:q] ||
      { item_type_in: ['Sessions::Session'] })
    @versions = @search.result(distinct: true).includes(:user).order(id: :desc)
    if params[:chain_id].present?
      chain_id = params[:chain_id].to_i
      version = PaperTrail::Version.find(chain_id)
      @versions = @versions.where(whodunnit: version.whodunnit,
                                  session_id: version.session_id)
                           .where('id <= ?', chain_id)
    end
    @used_chains = []
    @chains_count = 0
    @chains = find_chains(chain_id)
    if chain_id
      @versions = @versions.where(id: @chains[@chains.values.first.first])
      params[:chain_id] = @chains.values.first.first
    end
    without_pagination(:versions)
    @versions = @versions.per(10)
  end

  private

  def find_chains(chain_id)
    chains = {}
    versions = @versions.reorder(nil).order({ whodunnit: :desc }, { session_id: :desc }, { created_at: :desc })
    chain_id ? PaperTrail::Version.find(chain_id) : versions.first
    prev_v = versions.first
    chain = []
    versions.each do |v|
      if prev_v.whodunnit == v.whodunnit &&
         prev_v.session_id == v.session_id &&
         (prev_v.created_at - v.created_at) <= 1.second
        chain << v.id
      else
        break if chain_id

        chains[chain.first] = chain
        chain = [v.id]
      end
      prev_v = v
    end
    chains[chain.first] = chain
    chains
  end
end
