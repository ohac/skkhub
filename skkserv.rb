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

class SKKSERVDic

  def initialize(host, port)
    @host, @port = host, port
  end

  def search(q)
    get do |io|
      io.syswrite("1#{q.encode('EUC-JP')} \n")
      r, s = [io], ""
      while IO.select(r)
        s << io.sysread(512)
        break if s[-1, 1] == "\n"
      end
      s.force_encoding('EUC-JP')
      s[2..-3].split("/") if s[0, 1] == '1'
    end
  end

  def get
    io = TCPSocket.new(@host, @port)
    a = yield io
    io.shutdown
    io.close
    a
  end

end

class EvalDic
  def search(q)
    e = eval(q) rescue nil
    ["#{q} => #{e}"]
  end
end

class WakarimasuDic
  def search(q)
    ["#{q}ですね。わかります。"]
  end
end

class SocialIme
  require 'net/http'
  require 'timeout'

  def search(q)
    begin
      kanji = nil
      timeout(3) do
        http = Net::HTTP.new('www.social-ime.com', 80)
        http.start do |h|
          res = h.get("/api/?string=#{URI.escape(q)}")
          kanji = res.body.to_s.force_encoding('EUC-JP').split(/[\n\t]/)
        end
      end
      kanji
    rescue
    end
  end

end

if $0 == __FILE__
  dictset = [
    SKKSERVDic.new('localhost', 1178),
    EvalDic.new,
    WakarimasuDic.new,
    SocialIme.new
  ]
  SKKServer.new.mainloop do |q|
    dictset.map{|d|d.search(q)}.select{|s|!s.nil?}.flatten
  end
end
