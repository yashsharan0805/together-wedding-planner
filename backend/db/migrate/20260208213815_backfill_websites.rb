class BackfillWebsites < ActiveRecord::Migration[8.1]
  def up
    Wedding.where.not(id: Website.select(:wedding_id)).find_each do |wedding|
      wedding.create_website!(pages: [{slug: ""}])
    end
  end

  def down
    # no-op
  end
end
