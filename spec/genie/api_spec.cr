require "../spec_helper"

module Genie::Model
  @@config : Config = Config.new

  describe Api do
    Spec.before_each { WebMock.reset }

    describe "get" do
      it "returns a reasonable respone on error" do
        api = Api.new(@@config)

        WebMock.stub(:get, "http://google.com")
               .to_return(body: "body", status: 500)

        expect_raises Api::Error do
          resp = api.get(URI.parse("http://google.com"))

          resp.success?.should eq(false)
          resp.error?.should eq(true)
          resp.status_code.should eq(500)
          resp.unauthorized?.should eq(false)
        end
      end

      it "returns reasonable response when not authorized" do
        api = Api.new(@@config)

        WebMock.stub(:get, "http://google.com")
               .to_return(body: "body", status: 401)

        expect_raises Api::AuthorizationError do
          resp = api.get(URI.parse("http://google.com"))

          resp.success?.should eq(false)
          resp.error?.should eq(true)
          resp.status_code.should eq(500)
          resp.unauthorized?.should eq(true)
        end
      end

      it "can request a URI" do
        api = Api.new(@@config)

        WebMock.stub(:get, "http://google.com")
               .to_return(body: "body")

        api.get(URI.parse("http://google.com"))
      end

      it "makes http get request" do
        api = Api.new(@@config)

        WebMock.stub(:get, "http://localhost/genie/v2/path")
               .to_return(body: "body")

        api.get("/path")
      end

      it "does not have auth header if no credentials" do
        api = Api.new(@@config)

        WebMock.stub(:get, "http://localhost/genie/v2/path")
               .to_return(body: "body")

        api.get("/path")
      end

      it "makes api requests with basic auth" do
        @@config.credentials = Credentials.new("admin", "admin")
        api = Api.new(@@config)

        WebMock.stub(:get, "http://localhost/genie/v2/path")
               .with(headers: {"Authorization" => "Basic admin:admin"})
               .to_return(body: "body")

        api.get("/path")
      end
    end

    describe "delete" do
      it "makes http DELETE request" do
        api = Api.new(@@config)

        WebMock.stub(:delete, "http://localhost/genie/v2/path")
               .to_return(body: "body")

        api.delete("/path")
      end

      it "returns a reasonable respone on error" do
        api = Api.new(@@config)

        WebMock.stub(:delete, "http://localhost/genie/v2/path")
               .to_return(body: "body", status: 500)

        expect_raises Api::Error do
          resp = api.delete("/path")

          resp.success?.should eq(false)
          resp.error?.should eq(true)
          resp.status_code.should eq(500)
          resp.unauthorized?.should eq(false)
        end
      end

      it "returns reasonable response when not authorized" do
        api = Api.new(@@config)

        WebMock.stub(:delete, "http://localhost/genie/v2/path")
               .to_return(body: "body", status: 401)

        expect_raises Api::AuthorizationError do
          resp = api.delete("/path")

          resp.success?.should eq(false)
          resp.error?.should eq(true)
          resp.status_code.should eq(500)
          resp.unauthorized?.should eq(true)
        end
      end

      it "makes api requests with basic auth" do
        api = Api.new(@@config)

        WebMock.stub(:delete, "http://localhost/genie/v2/path")
               .with(headers: {"Authorization" => "Basic admin:admin"})
               .to_return(body: "body")

        api.delete("/path")
      end
    end
  end
end
