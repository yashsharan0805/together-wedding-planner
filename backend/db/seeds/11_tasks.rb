# frozen_string_literal: true

ActsAsTenant.current_tenant.tasks.insert_all!(
  [
    { title: 'Find venue', completed_at: 1.month.ago },
    { title: 'Prepare list of guests', completed_at: 1.week.ago },
    { title: 'Send invitations', completed_at: nil },
    { title: 'Find dress', completed_at: nil },
    { title: 'Do paperwork', completed_at: nil },
    { title: 'Organize honeymoon', completed_at: nil }
  ]
)
