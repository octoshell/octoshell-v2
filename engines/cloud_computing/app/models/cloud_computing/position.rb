module CloudComputing
  class Position < ApplicationRecord
    # cloud_computing_positions
    belongs_to :item, inverse_of: :positions
    belongs_to :holder, polymorphic: true, autosave: true
    # belongs_to :request, -> { where(cloud_computing_positions: { holder_type: 'Request' }) },
    #                    foreign_key: 'holder_id'
    belongs_to :request, -> { where("#{Position.table_name}": { holder_type: Request.to_s }) },
                              foreign_key: 'holder_id'

    belongs_to :access, -> { where("#{Position.table_name}": { holder_type: Access.to_s }) },
                              foreign_key: 'holder_id'


    # validates :item_id, uniqueness: { scope: %i[holder_id holder_type] }
    has_many :from_links, class_name: 'PositionLink', inverse_of: :from, dependent: :destroy
    has_many :to_links, class_name: 'PositionLink', inverse_of: :to, dependent: :destroy

    scope :with_user_requests, (lambda do |user|
      # select('*, positions from (amount)')
      joins(:request).where(cloud_computing_requests: {
                              status: 'created', created_by_id: user
                            })

    end) # joins(positions: :requests)



    # scope :with_user_requests, lambda do |user|
    #   # select('*, positions from (amount)')
    #   joins(positions: :requests).where(cloud_computing_requests: {
    #                                       status: 'created', created_by: user
    #                                     }).uniq
    #
    # end # joins(positions: :requests)
        #                                  .where(cloud_computing_requests: { status: 'created', created_by: user })}
    # scope :joins_requests, -> { joins('INNER JOIN cloud_computing_requests AS c_r ON c_r.id = cloud_computing_positions.holder_id AND
    #    cloud_computing_positions.holder_type=\'CloudComputing::Request\' ') }

    validates :item, :holder, presence: true

    # validate do
    #   if item&.max_count && amount.present? && amount > item.max_count
    #     errors.add :amount, 'error'
    #   end
    # end

    def name
      item.name
    end

  end

end
