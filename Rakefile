# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/android'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'rm-android-jni'
  app.api_version = '23'
  app.vendor_project jar: 'vendor/dummy.jar', native: ["vendor/x86/libhello-jni.so"]
end
