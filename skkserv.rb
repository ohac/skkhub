#!/usr/bin/ruby1.9.1
# -*- coding: utf-8; -*-
require "thread"
require "socket"

class SKKServer

  def mainloop
    accept_clients do |s|
      while cmdbuf = s.sysread(512)
        t = case cmdbuf[0, 1]
            when '1'
              q = cmdbuf.split[0]
              q.slice!(0)
              q.force_encoding('EUC-JP')
              a = yield(q.encode('UTF-8')).map{|i|i.encode('EUC-JP')}
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
    server = TCPServer.open(23232) # or 1178
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

if $0 == __FILE__
  SKKServer.new.mainloop do |q|
    e = begin
          eval q
        rescue
        end
    a = []
    a << "#{q} => #{e}"
    a << "#{q}ですね。わかります。"
    []
  end
end