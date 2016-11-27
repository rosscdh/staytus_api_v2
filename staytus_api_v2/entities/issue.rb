module StaytusApiV2
  module Entities
    class Issue < Grape::Entity
      expose :identifier, :title, :updated_at
      expose :state, as: :current_action
      expose :updates, using: StaytusApiV2::Entities::IssueUpdate
      expose :service_status, merge: true, using: StaytusApiV2::Entities::ServiceStatus
    end
  end
end
