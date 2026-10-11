# frozen_string_literal: true

Group.create!(name: "Jim's guests", icon: 'pi pi-heart').tap do |parent|
  parent.children.create!(name: "Jim's family", icon: 'pi pi-users').tap do |family|
    family.children.create!(name: "Jim's close family", icon: 'pi pi-home')
    family.children.create!(name: "Jim's cousins", icon: 'pi pi-home')
    family.children.create!(name: "Jim's relatives", icon: 'pi pi-home')
  end
  parent.children.create!(name: "Jim's friends", icon: 'pi pi-bullseye')
  parent.children.create!(name: "Jim's work", icon: 'pi pi-desktop').tap do |work|
    work.children.create!(name: "Jim's besties at work", icon: 'pi pi-briefcase')
  end
end

Group.create!(name: "Pam's guests", icon: 'pi pi-heart-fill').tap do |parent|
  parent.children.create!(name: "Pam's family", icon: 'pi pi-users').tap do |family|
    family.children.create!(name: "Pam's close family", icon: 'pi pi-home')
    family.children.create!(name: "Pam's cousins", icon: 'pi pi-home')
    family.children.create!(name: "Pam's relatives", icon: 'pi pi-home')
  end
  parent.children.create!(name: "Pam's friends", icon: 'pi pi-bullseye')
  parent.children.create!(name: "Pam's work", icon: 'pi pi-desktop').tap do |work|
    work.children.create!(name: "Pam's besties at work", icon: 'pi pi-briefcase')
  end
end

Group.create!(name: 'Common guests', icon: 'pi pi-users').tap do |parent|
  parent.children.create!(name: 'College friends', icon: 'pi pi-calculator')
  parent.children.create!(name: 'High school friends', icon: 'pi pi-crown')
  parent.children.create!(name: 'Childhood friends', icon: 'pi pi-envelope')
end

'red'.dup.paint.palette.triad(as: :hex).zip(Group.roots).each do |(color, group)|
  group.update!(color: color.paint.desaturate(40))
end

Group.roots.each(&:colorize_children)
