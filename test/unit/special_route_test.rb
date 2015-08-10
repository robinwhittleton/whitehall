require 'test_helper'
require "gds_api/publishing_api"

class SpecialRouteTest < ActiveSupport::TestCase
  def special_routes
    %w[
      /government
      /courts-tribunals
    ]
  end

  test ".publish_all publishes this app's special routes" do
    stub_request(:put, /publishing-api/)
    SpecialRoute.publish_all(GdsApi::PublishingApi.new(Plek.find("publishing-api")))

    special_routes.each do |base_path|
      assert_requested :put, %r{.*publishing-api.*?/content#{base_path}}
    end
  end

  test ".publish_all publishes the routes as prefixes" do
    publishing_api = stub(:publishing_api)
    publishing_api.stubs(:put_content_item)

    special_routes.each do |base_path|
      publishing_api.expects(:put_content_item).with(
        base_path,
        has_entries(
          format: "special_route",
          routes: [
            {
              path: base_path,
              type: "prefix",
            }
          ],
          publishing_app: "whitehall",
          rendering_app: "whitehall-frontend",
          update_type: "major",
        )
      )
    end

    SpecialRoute.publish_all(publishing_api)
  end
end
