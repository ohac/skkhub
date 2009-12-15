# -*- coding: utf-8 -*-
module SKKHub

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
            kanji = res.body.to_s.force_encoding('EUC-JP').encode('UTF-8').split("\n")
            kanji = kanji.map{|s|s.split("\t")}
            s = kanji.map(&:size)
            kanji = s.reduce(&:*).times.map do |i|
              m = s.map{|j|(i%j).tap{i=i/j}}
              kanji.zip(m).map{|k,l|k[l]}.join
            end
          end
        end
        kanji
      rescue
      end
    end

  end

end
