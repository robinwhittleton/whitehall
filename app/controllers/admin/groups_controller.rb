class Admin::GroupsController < Admin::BaseController
  before_filter :load_organisation
  before_filter :load_group, only: [:edit, :update, :destroy]

  def index
    @groups = Group.with_translations_for(:organisation).order("organisation_translations.name, groups.name")
  end

  def new
    @group = @organisation.groups.build
    5.times { @group.group_memberships.build }
  end

  def create
    @group = @organisation.groups.build(group_params)
    if @group.save
      redirect_to admin_organisation_path(@organisation, anchor: "groups"), notice: %{"#{@group.name}" created.}
    else
      render action: "new"
    end
  end

  def edit
    @group = Group.find(params[:id])
    5.times { @group.group_memberships.build }
  end

  def update
    if @group.update_attributes(group_params)
      redirect_to admin_organisation_path(@organisation, anchor: "groups"), notice: %{"#{@group.name}" updated.}
    else
      render action: "edit"
    end
  end

  def destroy
    if @group.destroy
      redirect_to admin_organisation_path(@organisation, anchor: "groups"), notice: %{"#{@group.name}" destroyed.}
    else
      message = "Cannot destroy a group with members."
      redirect_to admin_organisation_path(@organisation, anchor: "groups"), alert: message
    end
  end

  private

  def load_organisation
    @organisation = Organisation.friendly.find(params[:organisation_id])
  end

  def load_group
    @group = Group.find(params[:id])
  end

  def group_params
    params.require(:group).permit(
      :name, :description,
      group_memberships_attributes: [:id, :person_id, :_destroy]
    )
  end
end
