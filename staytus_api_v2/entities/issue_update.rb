module StaytusApiV2
  module Entities
    class IssueUpdate < Grape::Entity
      expose :state, as: :current_action
      expose :text, :updated_at, :identifier
      expose :service_status, merge: true, using: StaytusApiV2::Entities::ServiceStatus
      expose :user, using: StaytusApiV2::Entities::User
    end
  end
end
