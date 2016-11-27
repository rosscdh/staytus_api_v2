
module StaytusApiV2
  class API < Grape::API
    # Pagination
    include Grape::Kaminari
    paginate per_page: 10, max_per_page: 10, offset: 5

    version 'v2', using: :path, vendor: 'staytus'
    format :json
    prefix :api

    helpers do
      def token
        #@current_user ||= User.authorize!(env)
        if Rails.env == 'development'
          true
        else
          token = ApiToken.where(:token => request.headers['X-Auth-Token'], :secret => request.headers['X-Auth-Secret']).first

          if token.is_a?(ApiToken)
            token
          else
            nil
          end
        end
      end

      def authenticate!
        error!('401 Unauthorized: Invalid API credentials provided', 401) unless token
      end
    end

    before do
      authenticate!
    end

    resource :issues do
      desc 'GET all issues.'
      get '' do
        issues = Issue.ordered.includes(:service_status, :user)
        paginate(Kaminari.paginate_array(present issues, with: StaytusApiV2::Entities::Issue))
      end

      desc 'CREATE an issue.'
      params do
        requires :title, :type => String, desc: 'A title for this Issue.'
        requires :text, :type => String, desc: 'Initial Text for this Isssue.'
        requires :state, :type => String, values: Issue::STATES, desc: "One of ${Issue::STATES}"
        requires :status, :type => String, values: ServiceStatus.all.pluck(:permalink), desc: "One of ${ServiceStatus.all.pluck(:permalink)}."
        optional :services, :type => Array, values: Service.all.pluck(:permalink), desc: "One of ${Service.all.pluck(:permalink)}"
        optional :notify, :type => Boolean, default: false, desc: 'Should we Notify Subscribers.'
      end
      post do
        issue = Issue.create!({
          :title              => params[:title],
          :initial_update     => params[:text],
          :state              => params[:state],
          :service_status_id  => ServiceStatus.where(permalink: params[:status]).first.id,
          :services           => Service.where(permalink: params[:services]) || Service.all,
          :notify             => params[:notify],
        })
        present issue, with: StaytusApiV2::Entities::Issue
      end

      desc 'UPDATE an issue.'
      params do
        requires :identifier, type: String, desc: 'Issue identifier UUID.'

        requires :title, :type => String, desc: 'A title for this Issue.'
        requires :state, :type => String, values: Issue::STATES, desc: "One of ${Issue::STATES}"
        requires :status, :type => String, values: ServiceStatus.all.pluck(:permalink), desc: "One of ${ServiceStatus.all.pluck(:permalink)}."
        optional :services, :type => Array, values: Service.all.pluck(:permalink), desc: "One of ${Service.all.pluck(:permalink)}"
        optional :notify, :type => Boolean, default: false, desc: 'Should we Notify Subscribers.'
      end
      patch ':identifier' do
        issue = Issue.find_by_identifier(params[:identifier])
        issue.update!({
          :title              => params[:title],
          :state              => params[:state],
          :service_status_id  => ServiceStatus.where(permalink: params[:status]).first.id,
          :services           => Service.where(permalink: params[:services]) || Service.all,
          :notify             => params[:notify],
        })
        present issue, with: StaytusApiV2::Entities::Issue
      end

      desc 'GET an issue.'
      params do
        requires :identifier, type: String, desc: 'Issue identifier UUID.'
      end
      route_param :identifier do
        get do
          issue = Issue.find_by_identifier(params[:identifier])
          present issue, with: StaytusApiV2::Entities::Issue
        end
      end

      desc 'DELETE an issue.'
      params do
        requires :identifier, type: String, desc: 'Issue ID.'
      end
      delete ':identifier' do
          issue = Issue.find_by_identifier(params[:identifier])
          issue.destroy
          nil
      end

      #
      # Do an Issue Update Addition 
      #
      desc 'List issue-updates.'
      params do
        requires :identifier, type: String, desc: 'Issue ID.'
      end
      get ':identifier/updates' do
        issue = Issue.find_by_identifier!(params[:identifier])
        paginate(Kaminari.paginate_array(present issue.updates, with: StaytusApiV2::Entities::IssueUpdate))
      end

      desc 'Create an issue-update.'
      params do
        requires :identifier, type: String, desc: 'Issue ID.'

        requires :state, type: String, desc: 'New state'
        requires :text, type: String, desc: 'Update Message'
      end
      post ':identifier/updates' do
        issue = Issue.find_by_identifier!(params[:identifier])
        update = IssueUpdate.create({
          :issue    => issue,
          :state    => params[:state],
          :text     => params[:text]
        })
        present update, with: StaytusApiV2::Entities::IssueUpdate
      end

      desc 'Get an issue update'
      params do
        requires :identifier, type: String, desc: 'Issue ID.'
        requires :update_identifier, type: String, desc: 'Issue Update ID.'
      end
      get ':identifier/updates/:update_identifier' do
        issue = Issue.find_by_identifier!(params[:identifier])
        update = issue.updates.find_by_identifier!(params[:update_identifier])
        present update, with: StaytusApiV2::Entities::IssueUpdate
      end

      desc 'Update a specific issue-update.'
      params do
        requires :identifier, type: String, desc: 'Issue ID.'
        requires :update_identifier, type: String, desc: 'Issue Update ID.'

        requires :state, type: String, desc: 'New state'
        requires :text, type: String, desc: 'Update Message'
      end
      patch ':identifier/updates/:update_identifier' do
        issue = Issue.find_by_identifier!(params[:identifier])
        update = issue.updates.find_by_identifier!(params[:update_identifier])
        update.update({
          :state    => params[:state],
          :text     => params[:text],
        })
        present update, with: StaytusApiV2::Entities::IssueUpdate
      end

      desc 'Update a specific issue-update.'
      params do
        requires :identifier, type: String, desc: 'Issue ID.'
        requires :update_identifier, type: String, desc: 'Issue Update ID.'
      end
      delete ':identifier/updates/:update_identifier' do
        issue = Issue.find_by_identifier!(params[:identifier])
        update = issue.updates.find_by_identifier!(params[:update_identifier])
        update.destroy
        nil
      end

    end
  end
end