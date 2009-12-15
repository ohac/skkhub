# -*- coding: utf-8 -*-
module SKKHub

  class EvalDic
    def search(q)
      e = eval(q) rescue nil
      ["#{q} => #{e}"]
    end
  end

end
