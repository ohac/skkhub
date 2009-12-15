# -*- coding: utf-8 -*-
module SKKHub

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

end
