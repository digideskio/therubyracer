require 'spec_helper'

describe V8::Portal::Proxies do
  include V8::ExtSpec

  context "for Ruby objects which are embedded into javascript" do
    
    it "requires a Ruby object which is the actual object that is proxied" do
      expect {subject.register_javascript_proxy c::Object::New()}.should raise_error(ArgumentError)
    end
    
    it "can only register proxies which are low-level JavaScript objects" do
      expect {subject.register_javascript_proxy Object.new, :for => Object.new}.should raise_error(ArgumentError)
    end
    it "holds a hard reference to any ruby object which is linked to a javascript proxy" do
      object = Object.new
      ObjectSpace.define_finalizer(object, method(:finalize))
      subject.register_javascript_proxy c::Object::New(), :for => object
      object = nil
      afterwards {@finalized.should be_false}
    end

    it "releases the hard reference if its corresponding javascript object has been garbage collected" do
      object = Object.new
      ObjectSpace.define_finalizer(object, method(:finalize))
      subject.register_javascript_proxy c::Object::New(), :for => object
      object = nil
      v8_gc
      afterwards {@finalized.should be_true}
    end
  end

  context "for a JavaScript objects which are embedded into Ruby" do
    it "holds a weak referece to any javascript object which is "
  end
  
  private
  
  def finalize(object_id)
    @finalized = true
  end
  
  def afterwards(&block)
    @after ||= []
    @after << block if block_given?
  end
  
  after do
    ruby_gc do
      @after.each(&:call) if @after
    end
  end
  
end