require 'spec_helper'

feature Role do
  let(:conference) { create(:conference) }
  let(:role_names) { Role.all.each.map(&:name) }

  shared_examples 'edit role successfully' do |role_name, by_role_name|
    let!(:role) { Role.find_by(name: role_name, resource: conference) }
    let!(:by_role) { Role.find_by(name: by_role_name, resource: conference) }
    let!(:user_to_sign_in) { create(:user, role_ids: [by_role.id]) }

    before :each do
      sign_in user_to_sign_in
      visit admin_conference_roles_path(conference.short_title)
    end

    scenario 'edits role', feature: true, js: true do
      click_link('Edit', href: edit_admin_conference_role_path(conference.short_title, role_name))
      fill_in 'role_description', with: 'changed description'
      click_button 'Update Role'
      role.reload

      expect(flash).to eq("Successfully updated role #{role_name}")
      expect(role.description).to eq('changed description')
    end
  end

  shared_examples 'add remove users successfully' do |role_name, by_role_name|
    let!(:role) { Role.find_by(name: role_name, resource: conference) }
    let!(:user_with_role) { create(:user, role_ids: [role.id]) }
    let!(:by_role) { Role.find_by(name: by_role_name, resource: conference) }
    let!(:user_to_sign_in) { create(:user, role_ids: [by_role.id]) }
    let!(:user_with_no_role) { create :user }

    before :each do
      sign_in user_to_sign_in
      visit admin_conference_roles_path(conference.short_title)
    end

    scenario 'adds role', feature: true, js: true do
      click_link('Users', href: admin_conference_role_path(conference.short_title, role_name))

      fill_in 'user_email', with: user_with_no_role.email
      click_button 'Add'
      user_with_no_role.reload

      expect(user_with_no_role.has_role?(role.name, conference)).to eq true
    end

    scenario 'removes role', feature: true, js: true do
      click_link('Users', href: admin_conference_role_path(conference.short_title, role_name))

      bootstrap_switch = first('td').find('.bootstrap-switch-container')
      bootstrap_switch.click

      expect(find('.alert').text).to eq "×Successfully removed role #{role_name} from user #{user_with_role.email}"
      expect(by_role_name).to eq(role_name) | eq('organizer')
      expect(user_with_role.has_role?(role_name, conference)).to eq false
    end
  end

  shared_examples 'add remove users not successfully' do |role_name, by_role_name|
    let!(:role) { Role.find_by(name: role_name, resource: conference) }
    let!(:user_with_role) { create(:user, role_ids: [role.id]) }
    let!(:by_role) { Role.find_by(name: by_role_name, resource: conference) }
    let!(:user_to_sign_in) { create(:user, role_ids: [by_role.id]) }
    let!(:user_with_no_role) { create :user }

    before :each do
      sign_in user_to_sign_in
      visit admin_conference_roles_path(conference.short_title)
    end

    scenario 'adds role', feature: true, js: true do
      click_link('Users', href: admin_conference_role_path(conference.short_title, role_name))

      expect(page.has_field?('user_email')).to eq false
    end

    scenario 'removes role', feature: true, js: true do
      click_link('Users', href: admin_conference_role_path(conference.short_title, role_name))

      expect(first('td').has_css?('.bootstrap-switch-container')).to eq false
    end
  end

  shared_examples 'edit role not successfully' do |role_name, by_role_name|
    let!(:role) { Role.find_by(name: role_name, resource: conference) }
    let!(:by_role) { Role.find_by(name: by_role_name, resource: conference) }
    let!(:user_to_sign_in) { create(:user, role_ids: [by_role.id]) }

    before(:each) do
      sign_in user_to_sign_in
      visit admin_conference_roles_path(conference.short_title)
    end
    scenario 'edits role' do
      expect(page.has_link?('Edit', href: edit_admin_conference_role_path(conference.short_title, role_name))).to eq false
    end
  end

  context 'organizer' do
    Role.all.each.map(&:name).each do |role|
      describe "for #{role} role" do
        it_behaves_like 'add remove users successfully', role, 'organizer'
        it_behaves_like 'edit role successfully', role, 'organizer'
      end
    end
  end

  context 'volunteers_coordinator' do
    describe 'for volunteers_coordinator role' do
      it_behaves_like 'add remove users successfully', 'volunteers_coordinator', 'volunteers_coordinator'
      it_behaves_like 'edit role not successfully', 'volunteers_coordinator', 'volunteers_coordinator'
    end

    Role.all.each.map(&:name).reject { |role| role == 'volunteers_coordinator' }.each do |role|
      describe "for #{role} role" do
        it_behaves_like 'add remove users not successfully', role, 'volunteers_coordinator'
        it_behaves_like 'edit role not successfully', role, 'volunteers_coordinator'
      end
    end
  end

  context 'cfp' do
    describe 'for cfp role' do
      it_behaves_like 'add remove users successfully', 'cfp', 'cfp'
      it_behaves_like 'edit role not successfully', 'cfp', 'cfp'
    end

    Role.all.each.map(&:name).reject { |role| role == 'cfp' }.each do |role|
      describe "for #{role} role" do
        it_behaves_like 'add remove users not successfully', role, 'cfp'
        it_behaves_like 'edit role not successfully', role, 'cfp'
      end
    end
  end

  context 'info_desk' do
    describe 'for info_desk role' do
      it_behaves_like 'add remove users successfully', 'info_desk', 'info_desk'
      it_behaves_like 'edit role not successfully', 'info_desk', 'info_desk'
    end

    Role.all.each.map(&:name).reject { |role| role == 'info_desk' }.each do |role|
      describe "for #{role} role" do
        it_behaves_like 'add remove users not successfully', role, 'info_desk'
        it_behaves_like 'edit role not successfully', role, 'info_desk'
      end
    end
  end
end
