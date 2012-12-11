require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe SexyScopes::ActiveRecord do
  it "should extend ActiveRecord::Base" do
    ActiveRecord::Base.should be_extended_by SexyScopes::ActiveRecord
  end
  
  describe ".attribute(name)" do
    subject { User.attribute(:username) }
    
    it "should return an Arel attribute for the given name" do
      subject.should eql User.arel_table[:username]
    end
    
    it { should be_extended_by SexyScopes::ExpressionWrappers }
  end
  
  describe ".sql_literal(expression)" do
    subject { User.sql_literal('NOW()') }
    
    it "should return an Arel literal for given expression" do
      subject.should eql(::Arel.sql('NOW()'))
    end
    
    it "should be aliased as `sql`" do
      SexyScopes::ActiveRecord.instance_method(:sql).should ==
        SexyScopes::ActiveRecord.instance_method(:sql_literal)
    end
    
    it { should be_extended_by SexyScopes::ExpressionWrappers }
    
    it { should be_extended_by SexyScopes::PredicateWrappers }
  end
  
  context "dynamic method handling (method_missing/respond_to?)" do
    it "should delegate to `attribute` when the method name is the name of an existing column" do
      User.should respond_to(:username)
      User.should_receive(:attribute).with(:username).once.and_return(:ok)
      User.username.should == :ok
    end
    
    ruby_19 do
      it "should return a Method object for an existing column" do
        lambda { User.method(:username) }.should_not raise_error
      end
    end
    
    it "should raise NoMethodError otherwise" do
      User.should_not respond_to(:foobar)
      lambda { User.foobar }.should raise_error NoMethodError
    end
  end
end