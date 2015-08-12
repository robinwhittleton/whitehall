class Unpublishing < ActiveRecord::Base
  belongs_to :edition
  belongs_to :statistics_announcement

  validates :unpublishing_reason, :document_type, :slug, presence: true
  validate :edition_or_statistics_announcement_present
  validates :explanation, presence: { message: "must be provided when withdrawing", if: :withdrawn? }
  validates :alternative_url, presence: { message: "must be provided to redirect the document", if: :redirect? }
  validates :alternative_url, uri: true, allow_blank: true
  validates_format_of :alternative_url,
    with: %r(\A#{Whitehall.public_protocol}://#{Whitehall.public_host}/),
    message: "must be in the form of #{Whitehall.public_protocol}://#{Whitehall.public_host}/example",
    allow_blank: true
  validate :redirect_not_circular

  after_update :publish_to_publishing_api

  def self.from_slug(slug, type)
    where(slug: slug, document_type: type.to_s).last
  end

  def redirect?
    redirect || unpublishing_reason == UnpublishingReason::Consolidated
  end

  def withdrawn?
    unpublishing_reason == UnpublishingReason::Withdrawn
  end

  def unpublishing_reason
    UnpublishingReason.find_by_id unpublishing_reason_id
  end

  def reason_as_sentence
    unpublishing_reason.as_sentence
  end

  # Because the edition may have been deleted, we override the slug in case it
  # has bee pre-fixed with 'deleted-'
  def document_path
    if edition
      Whitehall.url_maker.public_document_path(edition, id: slug)
    elsif statistics_announcement
      raise "Not sure what this should be - maybe statistics_announcement.public_path ?"
    end
  end

  # Because the edition may have been deleted, we need to find it unscoped to
  # get around the default scope.
  def edition
    Edition.unscoped.find(edition_id) if edition_id
  end

  def translated_locales
    edition.translated_locales
  end

private
  def redirect_not_circular
    if alternative_url.present?
      if document_path == alternative_path
        errors.add(:alternative_url, "cannot redirect to itself")
      end
    end
  end

  def edition_or_statistics_announcement_present
    if edition.nil? && statistics_announcement.nil?
      errors.add(:base, "edition or statistics announcement needs to be set")
    end
  end

  def alternative_path
    URI.parse(alternative_url).path
  rescue URI::InvalidURIError
    nil
  end

  def publish_to_publishing_api
    Whitehall::PublishingApi.publish_async(self, 'minor')
  end
end
