class CreateInvitationConfigs < ActiveRecord::Migration[8.1]
  def change
    create_table :invitation_configs, id: :uuid do |t|
      t.references :settings, null: false, type: :uuid, foreign_key: { on_delete: :cascade }, index: {unique: true}

      # QR code settings
      t.point :qr_position, null: false, default: '(0, 0)'
      t.integer :qr_size_px, null: false, default: 250
      t.string :qr_color, null: false, default: '#000000'
      t.string :qr_fill_color

      # Guest names text
      t.string :text_color, null: false, default: '#000000'
      t.integer :text_font_size, null: false, default: 20
      t.string :text_font_family, null: false, default: "Arial"
      t.integer :text_font_weight, null: false, limit: 2, default: 400
      t.point :text_position, null: false, default: '(0, 300)'
      t.string :text_align, null: false, default: :left

      t.timestamps
    end

    [:qr_color, :qr_fill_color, :text_color].each do
      add_check_constraint :invitation_configs, "#{it} is null or #{it} ~* '^#[a-fA-F0-9]{6}$'", name: "hex_#{it}", if_not_exists: true
    end

    add_check_constraint :invitation_configs, "qr_size_px >= 50", name: "qr_size_limits", if_not_exists: true
    add_check_constraint :invitation_configs, "text_font_size >= 0", name: "font_size_positive", if_not_exists: true
    add_check_constraint :invitation_configs, "text_font_weight between 100 and 900 and text_font_weight % 100 = 0", name: "text_font_weight", if_not_exists: true

    [:qr_position, :text_position].each do
      add_check_constraint :invitation_configs, "#{it}[0] >= 0 and #{it}[1] >= 0", name: "#{it}_positive", if_not_exists: true
    end

    add_check_constraint :invitation_configs, "text_align IN ('left', 'right', 'center')", name: :text_align_options, if_not_exists: true
  end
end
