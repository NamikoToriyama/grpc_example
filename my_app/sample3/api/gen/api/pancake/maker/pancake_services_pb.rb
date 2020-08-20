# Generated by the protocol buffer compiler.  DO NOT EDIT!
# Source: pancake.proto for package 'pancake.maker'

require 'grpc'
require 'pancake_pb'

module Pancake
  module Maker
    module PancakeBakerService
      class Service

        include GRPC::GenericService

        self.marshal_class_method = :encode
        self.unmarshal_class_method = :decode
        self.service_name = 'pancake.maker.PancakeBakerService'

        # Bakes pancakes of the request
        # Returns Baked pancakes
        rpc :Bake, ::Pancake::Maker::BakeRequest, ::Pancake::Maker::BakeResponse
        # Returns the number of pancakes 
        rpc :Report, ::Pancake::Maker::ReportRequest, ::Pancake::Maker::ReportResponse
      end

      Stub = Service.rpc_stub_class
    end
  end
end
