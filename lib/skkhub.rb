# -*- coding: utf-8 -*-
require "thread"
require "socket"
require "fileutils"
require "skkhub/config"

module SKKHub

  class SKKServer

    def mainloop
      filter = SKKHub::AZIKFilter.new
      accept_clients do |s|
        while cmdbuf = s.sysread(512)
          t = case cmdbuf[0, 1]
              when '1'
                q = cmdbuf.split[0]
                q.slice!(0)
                q.force_encoding('EUC-JP')
                q1 = q.encode('UTF-8')
                a1 = yield(q1)
                q2 = filter.pre_filter(q1)
                a2 = !q2.nil? ? yield(q2) : []
                a2.map!{|a3|filter.post_filter(a3.encode('UTF-8'))}
                a = (a1 + a2).map do |i|
                  i.encode('EUC-JP')} rescue '?'
                end
                a.empty? ? "4\n" : "1/#{a.join('/')}/\n"
              when '2'
                'skkservtest-0.0.1 '
              when '3'
                'host:ip: '
              end
          s.write(t)
        end
      end
    end

    def accept_clients
      server = TCPServer.open(11178) # or 1178
      loop do
        s = server.accept
        Thread.start(s) do |s2|
          begin
            yield(s2)
          ensure
            s2.shutdown
            s2.close
          end
        end
      end
    end

  end

  APP_NAME = 'skkhub'

  config.system.set_default :conf_dir, File.expand_path('~/.skkhub')
  CONF_DIR = config.system.conf_dir

  config.system.set_default :conf_file, CONF_DIR + '/config'
  CONF_FILE = config.system.conf_file

  def self.run
    config.set_default :plugins, [
      "skkserv",
      "eval",
      "example",
      "socialime",
      "aamaker",
      "azik",
    ]
    config.set_default :dictset, [
      ['SKKSERVDic', ['localhost', 1178]],
      'EvalDic',
      'WakarimasuDic',
      'SocialIme',
      'AAMaker',
    ]
    unless File.exist?(CONF_DIR)
      FileUtils.mkdir(CONF_DIR)
      FileUtils.touch(CONF_FILE)
    end
    load CONF_FILE
    config.plugins.each do |plugin|
      load "plugins/#{plugin}.rb"
    end
    dictset = config.dictset.map do |dict|
      case dict
      when Array
        Class.class_eval(dict[0]).new(*dict[1])
      else
        Class.class_eval(dict).new
      end
    end
    SKKServer.new.mainloop do |q|
      dictset.map{|d|d.search(q)}.select{|s|!s.nil?}.flatten.map do |w|
        w.gsub(/\//, "\/")
      end
    end
  end

end
