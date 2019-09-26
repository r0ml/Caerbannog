
fileprivate let modname = "swift_module".cString(using:.utf8)

fileprivate var myextension_methods : [PyMethodDef] = [
  PyMethodDef(ml_name: nil, ml_meth: nil, ml_flags: 0, ml_doc: nil)
]

fileprivate var moduleDef : PyModuleDef!

fileprivate var slots = [
  PyModuleDef_Slot.init(slot: Py_mod_exec, value: mm),
  PyModuleDef_Slot.init(slot: 0, value: nil)
]

fileprivate let mm = unsafeBitCast(callbackWrapper, to: Optional<UnsafeMutableRawPointer>.self)
fileprivate let callbackWrapper : @convention(c) (PyObjectRef, UnsafeMutablePointer<PyModuleDef>?) -> PyObjectRef? = swift_module_install

fileprivate func initModuleFn() -> PyObjectRef? {
  // return PyModule_Create2(&moduleDef!, 3);
  moduleDef = PyModuleDef.init(m_base: PyModuleDef_Base(), m_name: modname,
                               m_doc: nil, m_size: 0,
                               m_methods: &myextension_methods,
                               m_slots: &slots,
                               m_traverse: nil,
                               m_clear: nil,
                               m_free: nil)
  return PyModuleDef_Init(&moduleDef)
}

fileprivate func swift_module_install(spec : PyObjectRef, def: UnsafeMutablePointer<PyModuleDef>!) -> PyObjectRef? {
      PyRun_SimpleStringFlags("""
  import stdout_capture
  import sys
  class StdoutCatcher:
      def write(self, stuff):
          stdout_capture.error_out(stuff)
  sys.stdout = StdoutCatcher()
  """, nil);
  
  return nil
}

open class SwiftModule {
  public init() {
    let _ = PyImport_AppendInittab(modname, initModuleFn );
  }
  
  public func addMethod( _ nm : String,  _ mf : @escaping PyCFunction ) {
    let j = nm.cString(using:.utf8)!
    let p = UnsafeMutablePointer<CChar>.allocate(capacity: j.count)
    for i in 0..<j.count { p[i] = j[i] }
    let ii = PyMethodDef(ml_name: p, ml_meth: mf, ml_flags: METH_VARARGS, ml_doc: nil)
    myextension_methods.insert(ii, at: 0)
  }
}
