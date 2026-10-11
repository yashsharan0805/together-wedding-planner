require_relative "../../app/models/page"

ActiveRecord::Type.register(:page, Page)
