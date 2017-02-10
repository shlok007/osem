require 'spec_helper'

describe 'admin/resources/index.html.haml' do
  let!(:conference) { create(:conference) }
  let!(:resource1) { create(:resource, conference: conference)}
  let!(:resource2) { create(:resource, conference: conference)}

  it 'renders all resources' do
    assign(:conference, conference)
    assign(:resources, [ resource1, resource2 ])

    render

    expect(rendered).to have_selector('table thead th:nth-of-type(1)', text: 'Name')
    expect(rendered).to have_selector('table thead th:nth-of-type(2)', text: 'Left ( Left/Total )')
    expect(rendered).to have_selector('table thead th:nth-of-type(3)', text: 'Used')
    expect(rendered).to have_selector('table thead th:nth-of-type(4)', text: 'Actions')

    expect(conference.resources.count).to eq 2
    expect(rendered).to have_selector('table tr:nth-of-type(1) td:nth-of-type(1)', text: resource1.id)
    expect(rendered).to have_selector('table tr:nth-of-type(1) td:nth-of-type(2)', text: resource1.name)

    expect(rendered).to have_selector('table tr:nth-of-type(2) td:nth-of-type(1)', text: resource2.id)
    expect(rendered).to have_selector('table tr:nth-of-type(2) td:nth-of-type(2)', text: resource2.name)
  end
end
