require 'spec_helper'

feature Role do
  let(:conference) { create(:conference) }

  shared_examples 'correctly succeeds or fails to' do |role_name, by_role_name|
    let!(:role) { Role.find_by(name: role_name, resource: conference) }
    let!(:user_with_role) { create(:user, role_ids: [role.id]) }
    let!(:by_role) { Role.find_by(name: by_role_name, resource: conference) }
    let!(:user_to_sign_in) { create(:user, role_ids: [by_role.id]) }
    let!(:user_with_no_role) { create :user }
    let!(:expected_role_names) { Role.all.each.map(&:name).reject { |name| name == role_name } }

    before :each do
      sign_in user_to_sign_in
      visit admin_conference_roles_path(conference.short_title)
    end

    scenario 'adds role', feature: true, js: true do
      click_link('Users', href: admin_conference_role_path(conference.short_title, role_name))

      if page.has_field?('user_email')
        fill_in 'user_email', with: user_with_no_role.email
        click_button 'Add'
        user_with_no_role.reload

        expect(user_with_no_role.has_role?(role.name, conference)).to eq true
        expect(by_role_name).to eq(role_name) | eq('organizer')
      else
        expect(by_role_name).to be_in(expected_role_names)
      end
    end

    scenario 'edits role', feature: true, js: true do
      if page.has_link?('Edit')
        click_link('Edit', href: edit_admin_conference_role_path(conference.short_title, role_name))
        fill_in 'role_description', with: 'changed description'
        click_button 'Update Role'
        role.reload

        expect(flash).to eq("Successfully updated role #{role_name}")
        expect(role.description).to eq('changed description')
        expect(by_role_name).to eq 'organizer'
      else
        expect(by_role_name).not_to eq 'organizer'
      end
    end

    scenario 'removes role', feature: true, js: true do
      click_link('Users', href: admin_conference_role_path(conference.short_title, role_name))

      if first('td').has_css?('.bootstrap-switch-container')
        bootstrap_switch = first('td').find('.bootstrap-switch-container')
        bootstrap_switch.click

        expect(find('.alert').text).to eq "×Successfully removed role #{role_name} from user #{user_with_role.email}"
        expect(by_role_name).to eq(role_name) | eq('organizer')
        expect(user_with_role.has_role?(role_name, conference)).to eq false
      else
        expect(by_role_name).to be_in(expected_role_names)
      end
    end
  end

  Role.all.each.map(&:name).repeated_permutation(2) do |role, by_role|
    context by_role do
      describe "for #{role} role" do
        it_behaves_like 'correctly succeeds or fails to', role, by_role
      end
    end
  end
end
