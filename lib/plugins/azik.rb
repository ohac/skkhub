# -*- coding: utf-8 -*-
module SKKHub

  class AZIKFilter

    def pre_filter(q)
      q[0..-3] + 't' if /っt\z/ === q
    end

    def post_filter(a)
      a2 = a.split(";")
      if a2.size == 1
        "#{a}っ"
      else
        "#{a2[0]}っ;testtest"
      end
    end

  end

end
