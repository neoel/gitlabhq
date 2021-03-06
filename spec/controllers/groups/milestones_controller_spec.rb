require 'spec_helper'

describe Groups::MilestonesController do
  let(:group) { create(:group) }
  let(:project) { create(:empty_project, group: group) }
  let(:project2) { create(:empty_project, group: group) }
  let(:user)    { create(:user) }
  let(:title) { '肯定不是中文的问题' }

  before do
    sign_in(user)
    group.add_owner(user)
    project.team << [user, :master]
    controller.instance_variable_set(:@group, group)
  end

  describe "#create" do
    it "creates group milestone with Chinese title" do
      post :create,
           group_id: group.id,
           milestone: { project_ids: [project.id, project2.id], title: title }

      expect(response).to redirect_to(group_milestone_path(group, title.to_slug.to_s, title: title))
      expect(Milestone.where(title: title).count).to eq(2)
    end

    it "redirects to new when there are no project ids" do
      post :create, group_id: group.id, milestone: { title: title, project_ids: [""] }
      expect(response).to render_template :new
      expect(assigns(:milestone).errors).not_to be_nil
    end
  end
end
