require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Skkhub" do
  it "fails" do
    d = SKKHub::WakarimasuDic.new
    d.search('a').should == ["aですね。わかります。"]
  end
end
