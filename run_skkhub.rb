#!/usr/bin/env ruby1.9.1
# -*- coding: utf-8 -*-

self_file =
  if File.symlink?(__FILE__)
    require 'pathname'
    Pathname.new(__FILE__).realpath
  else
    __FILE__
  end
$:.unshift(File.dirname(self_file) + "/lib")

require 'skkhub'
SKKHub::run

# Startup scripts for development
