require "unit/whitehall/authority/authority_test_helper"
require "ostruct"

class DepartmentEditorFatalityNoticeTest < ActiveSupport::TestCase
  def fatality_department_editor(id = 1)
    o = OpenStruct.new(id: id, handles_fatalities?: true)
    OpenStruct.new(id: id, gds_editor?: false, departmental_editor?: true, organisation: o)
  end

  def normal_department_editor(id = 1)
    o = OpenStruct.new(id: id, handles_fatalities?: false)
    OpenStruct.new(id: id, gds_editor?: false, departmental_editor?: true, organisation: o)
  end

  include AuthorityTestHelper

  test "can create a new fatality notice if their organisation can handle fatalities" do
    assert enforcer_for(fatality_department_editor, FatalityNotice).can?(:create)
  end

  test "cannot create a new fatality notice if their organisation cannot handle fatalities" do
    refute enforcer_for(normal_department_editor, FatalityNotice).can?(:create)
  end

  test "cannot do anything to a fatality notice if their organisation cannot handle fatalities" do
    user = normal_department_editor(10)
    edition = normal_fatality_notice
    enforcer = enforcer_for(user, edition)

    Whitehall::Authority::Rules::EditionRules.actions.each do |action|
      refute enforcer.can?(action)
    end
  end

  test "can see a fatality notice that is not access limited if their organisation can handle fatalities" do
    assert enforcer_for(fatality_department_editor, normal_fatality_notice).can?(:see)
  end

  test "can see a fatality notice that is access limited if it is limited to their organisation" do
    user = fatality_department_editor
    edition = limited_fatality_notice([user.organisation])
    assert enforcer_for(user, edition).can?(:see)
  end

  test 'cannot see a fatality notice that is access limited if it is limited an organisation they don\'t belong to' do
    user = fatality_department_editor(10)
    edition = limited_fatality_notice([OpenStruct.new(id: 100, handles_fatalities?: true)])

    refute enforcer_for(user, edition).can?(:see)
  end

  test "cannot do anything to a fatality notice they are not allowed to see" do
    user = fatality_department_editor(10)
    edition = limited_fatality_notice([OpenStruct.new(id: 100, handles_fatalities?: true)])
    enforcer = enforcer_for(user, edition)

    Whitehall::Authority::Rules::EditionRules.actions.each do |action|
      refute enforcer.can?(action)
    end
  end

  test "can create a new fatality notice that is not access limited if their organisation can handle fatalities" do
    assert enforcer_for(fatality_department_editor, normal_fatality_notice).can?(:create)
  end

  test "can make changes to a fatality notice that is not access limited if their organisation can handle fatalities" do
    assert enforcer_for(fatality_department_editor, normal_fatality_notice).can?(:update)
  end

  test "can make a fact check request for a edition if their organisation can handle fatalities" do
    assert enforcer_for(fatality_department_editor, normal_fatality_notice).can?(:make_fact_check)
  end

  test "can view fact check requests on a edition if their organisation can handle fatalities" do
    assert enforcer_for(fatality_department_editor, normal_fatality_notice).can?(:review_fact_check)
  end

  test "can publish a fatality notice if their organisation can handle fatalities" do
    assert enforcer_for(fatality_department_editor, normal_fatality_notice).can?(:publish)
  end

  test "can reject a fatality notice if their organisation can handle fatalities" do
    assert enforcer_for(fatality_department_editor, normal_fatality_notice).can?(:reject)
  end

  test "can force publish a fatality notice if their organisation can handle fatalities" do
    assert enforcer_for(fatality_department_editor, normal_fatality_notice).can?(:force_publish)
  end

  test "can make editorial remarks if their organisation can handle fatalities" do
    assert enforcer_for(fatality_department_editor, normal_fatality_notice).can?(:make_editorial_remark)
  end

  test "can review editorial remarks if their organisation can handle fatalities" do
    assert enforcer_for(fatality_department_editor, normal_fatality_notice).can?(:review_editorial_remark)
  end

  test 'can clear the "not reviewed" flag on fatality notice they didn\'t force publish if their organisation can handle fatalities' do
    assert enforcer_for(fatality_department_editor(10), force_published_fatality_notice(fatality_department_editor(100))).can?(:approve)
  end

  test 'cannot clear the "not reviewed" flag on fatality notices they did force publish if their organisation can handle fatalities' do
    user = fatality_department_editor
    refute enforcer_for(user, force_published_fatality_notice(user)).can?(:approve)
  end

  test "can limit access to a fatality notice if their organisation can handle fatalities" do
    assert enforcer_for(fatality_department_editor, normal_fatality_notice).can?(:limit_access)
  end

  test "cannot unpublish a fatality notice if their organisation can handle fatalities" do
    refute enforcer_for(fatality_department_editor, normal_fatality_notice).can?(:unpublish)
  end
end
