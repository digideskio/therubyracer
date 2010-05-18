#include "v8.h"
#include "v8_ref.h"
#include "v8_script.h"
#include "converters.h"

using namespace v8;

namespace {
  VALUE Compile(VALUE self, VALUE source, VALUE source_name) {
    Local<String> src(rr_rb2v8(source)->ToString());
    Local<String> src_name(rr_rb2v8(source_name)->ToString());
    return V8_Ref_Create(self, Script::Compile(src, src_name));
  }

  VALUE Run(VALUE self) {
    Local<Script> script(V8_Ref_Get<Script>(self));
    Local<Value> result(script->Run());
    return result.IsEmpty() ? Qnil : rr_v82rb(result);
  }
}

void rr_init_script() {
  VALUE ScriptClass = rr_define_class("Script");
  rr_define_singleton_method(ScriptClass, "Compile", Compile, 2);
  rr_define_method(ScriptClass, "Run", Run, 0);
  rb_funcall(ScriptClass, rb_intern("private_class_method"), 1, rb_str_new2("new"));
}
