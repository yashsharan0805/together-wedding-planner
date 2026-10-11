# frozen_string_literal: true

# A browser-facing adapter over LibreWeddingPlanner's existing wedding records.
# Authentication, wedding membership, CSRF and tenant scoping come from ApplicationController.
class PlannerController < ApplicationController
  before_action :reject_service_tokens
  rescue_from ActiveRecord::StaleObjectError do
    render json: { message: 'Someone updated this record. Refresh and try again.' }, status: :conflict
  end

  ENTITIES = {
    'tasks' => [Task, %i[title completed_at due_date assignee priority wedding_event_id]],
    'guests' => [Guest, %i[name status email phone side menu_restrictions special_requests]],
    'budget' => [Expense, %i[name amount pricing_type category wedding_event_id]],
    'vendors' => [PlannerVendor, %i[name category contact status notes wedding_event_id]],
    'events' => [WeddingEvent, %i[name date start_time venue notes]],
    'settings' => [Settings, %i[partner_one partner_two date venue currency budget]]
  }.freeze

  def index
    render json: snapshot
  end

  def create
    model, fields = entity
    raise ActionController::ParameterMissing, :entity if model == Settings

    model.transaction do
      record = model.new(record_params(fields))
      validate_event!(record)
      record.save!
      save_extras!(record)
    end
    render json: snapshot, status: :created
  end

  def update
    model, fields = entity
    model.transaction do
      record = model == Settings ? ActsAsTenant.current_tenant.settings : model.find(params[:id])
      record.lock!
      require_version!(record)
      record.assign_attributes(record_params(fields))
      validate_event!(record)
      record.save!
      save_extras!(record)
    end
    render json: snapshot
  end

  def destroy
    model, = entity
    raise ActionController::ParameterMissing, :entity if model == Settings

    model.transaction do
      record = model.find(params[:id])
      record.lock!
      require_version!(record)
      record.destroy!
    end
    render json: snapshot
  end

  private

  def reject_service_tokens
    head :forbidden if oauth?
  end

  def entity
    ENTITIES.fetch(params[:entity]) { raise ActionController::ParameterMissing, :entity }
  end

  def record_params(fields)
    params.require(:record).permit(*fields)
  end

  def require_version!(record)
    raise ActionController::ParameterMissing, :lock_version unless params[:lock_version].is_a?(Integer)
    raise ActiveRecord::StaleObjectError.new(record, 'update') unless record.lock_version == params[:lock_version]
  end

  def validate_event!(record)
    return unless record.respond_to?(:wedding_event_id) && record.wedding_event_id

    WeddingEvent.find(record.wedding_event_id) # lookup under the authenticated wedding tenant
  end

  def save_extras!(record)
    if record.is_a?(Guest) && params[:attendances]
      raise ActionController::ParameterMissing, :attendances unless params[:attendances].is_a?(ActionController::Parameters)

      params[:attendances].each_pair do |event_id, status|
        event = WeddingEvent.find(event_id)
        attendance = EventAttendance.find_or_initialize_by(guest: record, wedding_event: event)
        attendance.update!(status:)
      end
      # Attendance-only edits also increment the guest version, avoiding silent overwrites.
      record.touch
    end

    return unless record.is_a?(Expense) && params.key?(:paid)

    paid = BigDecimal(params[:paid].to_s, exception: false)
    raise ActionController::ParameterMissing, :paid unless paid && paid.finite? && paid >= 0

    delta = paid - record.payments.sum(:amount)
    record.payments.create!(title: 'Planner payment adjustment', amount: delta) unless delta.zero?
    record.touch unless delta.zero?
  end

  def snapshot
    settings = ActsAsTenant.current_tenant.settings
    potential_guests = Guest.potential.count
    documents = PlannerDocument.select(*PlannerDocument::METADATA_FIELDS, :task_id, :planner_vendor_id)
                               .order(created_at: :asc).group_by do |document|
      document.task_id ? ['tasks', document.task_id] : ['vendors', document.planner_vendor_id]
    end
    {
      settings: settings.as_json(only: %i[id lock_version partner_one partner_two date venue currency budget]),
      tasks: Task.order(created_at: :asc).map do |task|
        task.as_json(only: %i[id lock_version title completed_at due_date assignee priority wedding_event_id]).merge(
          documents: Array(documents[['tasks', task.id]]).map(&:metadata)
        )
      end,
      guests: Guest.includes(:event_attendances).order(name: :asc).map do |guest|
        guest.as_json(only: %i[id lock_version name status email phone side menu_restrictions special_requests]).merge(
          attendances: guest.event_attendances.to_h { |attendance| [attendance.wedding_event_id, attendance.status] }
        )
      end,
      budget: Expense.includes(:payments).order(created_at: :asc).map do |expense|
        expense.as_json(only: %i[id lock_version name amount pricing_type category wedding_event_id]).merge(
          paid: expense.payments.sum(&:amount),
          total: expense.pricing_type == 'per_person' ? expense.amount * potential_guests : expense.amount
        )
      end,
      vendors: PlannerVendor.order(created_at: :asc).map do |vendor|
        vendor.as_json(only: %i[id lock_version name category contact status notes wedding_event_id]).merge(
          documents: Array(documents[['vendors', vendor.id]]).map(&:metadata)
        )
      end,
      events: WeddingEvent.order(date: :asc, start_time: :asc).as_json(only: %i[id lock_version name date start_time venue notes]),
      members: Membership.includes(:user).order(created_at: :asc).map do |member|
        { id: member.id, email: member.user.email, status: member.status, deletable: member.user_id != current_user.id }
      end,
      user: current_user.as_json(only: %i[id email language])
    }
  end
end
