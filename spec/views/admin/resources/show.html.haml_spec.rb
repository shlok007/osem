require 'spec_helper'

describe 'admin/resources/show' do
  let!(:conference) { create(:conference) }
  let!(:resource) { create(:resource, conference: conference)}
  it 'renders all resources' do
    assign(:conference, conference)
    assign(:resource, resource)
    render
    expect(rendered).to include(resource.name)
    expect(rendered).to include(resource.used)
    expect(rendered).to include(resource.quantity_left)
  end
end
