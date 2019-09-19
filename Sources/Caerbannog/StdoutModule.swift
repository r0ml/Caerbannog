
import AppKit
import PythonWrapper

fileprivate func error_out(_ mm : PyObjectRef?, _ xx : PyObjectRef?) -> PyObjectRef? {
  //  var m = mm!.pointee
  let j = PyTuple_GetItem(xx, 0)
  let zz = PythonObject(retaining: j!)
  try! print( String(Python.str(zz))!, terminator: "" )
  //  let st = PyModule_GetState(&m)
  //  let err = st!.assumingMemoryBound(to: module_state.self).pointee.error
  // PyErr_SetString(err!, "something bad happened".cString(using: .utf8))
  Py_IncRef(&_Py_NoneStruct)
  return UnsafeMutablePointer(&_Py_NoneStruct);
}

fileprivate let error_out_name = "error_out".cString(using: .utf8)

fileprivate var myextension_methods : [PyMethodDef] = [
  PyMethodDef.init(ml_name: error_out_name, ml_meth: error_out, ml_flags: METH_VARARGS, ml_doc: nil),
  PyMethodDef.init(ml_name: nil, ml_meth: nil, ml_flags: 0, ml_doc: nil)
]

fileprivate var moduleDef : PyModuleDef?

fileprivate func PyInit_stdout_cap() -> PyObjectRef? {
  return PyModule_Create2(&moduleDef!, 3);
}

func initModule(_ modnam : String ) {
  let pmb  = PyModuleDef_Base()
  moduleDef = PyModuleDef.init(m_base: pmb, m_name: modnam.cString(using: .utf8),
                               m_doc: nil, m_size: -1,
                               m_methods: &myextension_methods,
                               m_slots: nil,
                               m_traverse: nil,
                               m_clear: nil,
                               m_free: nil)
  
  PyImport_AppendInittab(modnam, PyInit_stdout_cap);
  
}
