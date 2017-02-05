require 'spec_helper'

feature Role do
  let(:conference) { create(:conference) }
  let!(:other_user) { create :user }
  let!(:organizer_role) { Role.find_by(name: 'organizer', resource: conference) }
  let!(:organizer) { create(:user, role_ids: [organizer_role.id]) }

  shared_examples 'successfully' do |role_name|
    let!(:role) { Role.find_by(name: role_name, resource: conference) }
    before(:each) do
      sign_in organizer
      visit admin_conference_roles_path(conference.short_title)
    end

    scenario 'add role' do
      click_link('Users', href: admin_conference_role_path(conference.short_title, role.name))

      fill_in 'user_email', with: other_user.email

      click_button 'Add'
      other_user.reload

      expect(other_user.has_role?(role.name, conference)).to eq true
    end

    scenario 'edit role' do
      click_link('Edit', href: edit_admin_conference_role_path(conference.short_title, role.name))

      fill_in 'role_description', with: 'changed description'

      click_button 'Update Role'
      role.reload

      expect(flash).to eq("Successfully updated role #{role.name}")
      expect(role.description).to eq('changed description')
    end
  end

  context 'organizer' do
    describe 'for organizer role' do
      it_behaves_like 'successfully', 'organizer'
    end

    describe 'for volunteers_coordinator role' do
      it_behaves_like 'successfully', 'volunteers_coordinator'
    end

    describe 'for info_desk role' do
      it_behaves_like 'successfully', 'info_desk'
    end

    describe 'for cfp role' do
      it_behaves_like 'successfully', 'cfp'
    end
  end
end
