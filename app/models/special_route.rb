class SpecialRoute
  def self.publish_all(publishing_api)
    ROUTES.each do |route|
      route_type = route.delete(:type) || "prefix"
      route_spec = defaults.merge(route).merge(
        routes: [
          path: route[:base_path],
          type: route_type,
        ]
      )

      self.new(route_spec, publishing_api).publish
    end
  end

  def initialize(route_spec, publishing_api)
    @route_spec = route_spec
    @publishing_api = publishing_api
  end
  attr_reader :route_spec, :publishing_api

  def publish
    publishing_api.put_content_item(route_spec[:base_path], route_spec)
  end

private

  def self.defaults
    {
      format: "special_route",
      publishing_app: "whitehall",
      rendering_app: "whitehall-frontend",
      update_type: "major",
      public_updated_at: Time.zone.now.iso8601,
    }
  end

  ROUTES = [
    {
      base_path: "/government",
      content_id: "4672b1ff-f147-4d49-a5f4-4959588da5a8",
      title: "Government prefix",
      description: "The prefix route under which almost all government content is published.",
    },
    {
      base_path: "/courts-tribunals",
      content_id: "f990c58c-687a-4baf-b1a0-ec2d02c4d654",
      title: "Courts and tribunals",
      description: "The prefix route under which pages for courts and tribunals are published.",
    },
  ].freeze
end
