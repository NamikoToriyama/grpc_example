# frozen_string_literal: true

require Rails.root.join('app', 'gen', 'api', 'pancake', 'maker', 'pancake_pb')
require Rails.root.join('app', 'gen', 'api', 'pancake', 'maker', 'pancake_services_pb')
require 'grpc'

# grpcで使うロガーを定義する
module RubyLogger
  def logger
    LOGGER
  end
  
  LOGGER = Logger.new(STDOUT)
  LOGGER.level = :debug
end

# gRPCモジュールのLoggerを差し替える
module GRPC
extend RubyLogger
end

class Bakery
  include ActiveModel::Model

  # パンケーキのメニュー
  class Menu
    CLASSIC           = "classic"
    BANANA_AND_WRIP   = "banana_and_whip"
		BACON_AND_CHEESE  = "bacon_and_cheese"
		MIX_BARRY         = "mix_berry"
		BAKED_MARSHMALLOW = "baked_mashmallow"
    SPICY_CURRY       = "spicy_curry"
  end

  # メニューをproto buf用に変換する
  def self.pb_menu(menu)
    case menu
    when  Menu::CLASSIC
      :CLASSIC
    when  Menu::BANANA_AND_WRIP
      :BANANA_AND_WRIP
    when  Menu::BACON_AND_CHEESE
      :BACON_AND_CHEESE
    when  Menu::MIX_BARRY
      :MIX_BARRY
    when  Menu::BAKED_MARSHMALLOW
      :BAKED_MARSHMALLOW
    when  Menu::SPICY_CURRY
      :SPICY_CURRY
    else
      raise "unknown menu: #{menu}"
    end
  end

  def self.metadata
    {authorization: 'bearer hi/mi/tsu'}
  end

  # パンケーキを焼きます
  def self.bake_pancake(menu)
    # オブジェクトを作成
    req = Pancake::Maker::BakeRequest.new({
      menu: pb_menu(menu),
    })

    # munuが不正な場合, GRPC::InvalidArgumentがスローされる
    res = stub.bake(req, metadata:metadata)

    {
      chef_name:        res.pancake.chef_name,
      menu:             res.pancake.menu,
      technical_score:  res.pancake.technical_score,
      create_time:      res.pancake.create_time,
    }
  end

  # レポートをかく
  def self.report
    res = stub.report(Pancake::Maker::ReportRequest.new())

    res.report.bake_counts.map{|r| [r.menu, r.count]}.to_h
  end

  # IPアドレスとポート番号
  # ローカルホスト
  def self.config_dsn
    "127.0.0.1:50051"
  end

  # 平文のままデータを送信
  def self.stub
    Pancake::Maker::PancakeBakerService::Stub.new(
      config_dsn,
      :this_channel_is_insecure,
      timeout:  10
    )
  end
end
