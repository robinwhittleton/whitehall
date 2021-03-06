class FatalityNoticesController < DocumentsController
  def show
    @related_policies = document_related_policies
    @document = FatalityNoticePresenter.new(@document, @view_context)
    set_slimmer_format_header("news")
  end

  private

  def document_class
    FatalityNotice
  end
end
