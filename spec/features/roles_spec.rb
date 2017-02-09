require 'spec_helper'

feature Role do
  let(:conference) { create(:conference) }
  let!(:other_user) { create :user }
  let!(:organizer_role) { Role.find_by(name: 'organizer', resource: conference) }
  let!(:organizer) { create(:user, role_ids: [organizer_role.id]) }

  shared_examples 'addition of roles successfully' do |role_name, by_role_name|
    let!(:role) { Role.find_by(name: role_name, resource: conference) }
    let!(:by_role) { Role.find_by(name: by_role_name, resource: conference) }
    let!(:user_with_by_role) { create(:user, role_ids: [by_role.id]) }

    before(:each) do
      sign_in user_with_by_role
      visit admin_conference_roles_path(conference.short_title)
    end
    scenario 'adds role' do
      click_link('Users', href: admin_conference_role_path(conference.short_title, role.name))

      fill_in 'user_email', with: other_user.email

      click_button 'Add'
      other_user.reload

      expect(other_user.has_role?(role.name, conference)).to eq true
    end
  end

  shared_examples 'editing of roles successfully' do |role_name|
    let!(:role) { Role.find_by(name: role_name, resource: conference) }
    before(:each) do
      sign_in organizer
      visit admin_conference_roles_path(conference.short_title)
    end

    scenario 'edits role' do
      click_link('Edit', href: edit_admin_conference_role_path(conference.short_title, role.name))

      fill_in 'role_description', with: 'changed description'

      click_button 'Update Role'
      role.reload

      expect(flash).to eq("Successfully updated role #{role.name}")
      expect(role.description).to eq('changed description')
    end
  end

  ##
  #Organizers can manage users for all roles as well as edit all role.
  context 'organizer' do
    describe 'for organizer role' do
      it_behaves_like 'addition of roles successfully', 'organizer', 'organizer'
      it_behaves_like 'editing of roles successfully', 'organizer'
    end

    describe 'for volunteers_coordinator role' do
      it_behaves_like 'addition of roles successfully', 'volunteers_coordinator', 'organizer'
      it_behaves_like 'editing of roles successfully', 'volunteers_coordinator'
    end

    describe 'for info_desk role' do
      it_behaves_like 'addition of roles successfully', 'info_desk', 'organizer'
      it_behaves_like 'editing of roles successfully','info_desk'
    end

    describe 'for cfp role' do
      it_behaves_like 'addition of roles successfully','cfp', 'organizer'
      it_behaves_like 'editing of roles successfully','cfp'
    end
  end

  ##
  #User with role info_desk can only manage users for info_desk role
  context 'info_desk' do
    describe 'for info_desk role' do
      it_behaves_like 'addition of roles successfully', 'info_desk', 'info_desk'
    end
  end


  ##
  #Users with role cfp can only manage users for cfp role
  context 'cfp' do
    describe 'for cfp role' do
      it_behaves_like 'addition of roles successfully', 'cfp', 'cfp'
    end
  end

  ##
  #Users with role volunteers_coordinator can only manage users for volunteers_coordinator role
  context 'volunteers_coordinator' do
    describe 'for volunteers_coordinator role' do
      it_behaves_like 'addition of roles successfully', 'volunteers_coordinator', 'volunteers_coordinator'
    end
  end
end
