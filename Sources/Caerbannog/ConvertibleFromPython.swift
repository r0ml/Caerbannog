
import PythonWrapper
import Foundation

public protocol ConvertibleFromPython {
  init?(_ object: PythonObject)
}

extension PythonObject : ConvertibleFromPython {
  public init<T : ConvertibleToPython>(_ object: T) {
    self.init(object.pythonObject)
  }
  
  public init(_ object: PythonObject) {
    self.init(retaining: object.pointer)
  }
}

fileprivate extension PythonObject {
  /* I need the inout in order to get the address of the Python Type Object, which is needed for comparison */
  func isType(_ type : inout PyTypeObject) -> Bool {
//    let tz = self.pointer.pointee.ob_type.pointee
    let tz = self.pointer.pointee.ob_type
  //  return withUnsafePointer(to: tz) { (tzx) -> Bool in
      return withUnsafeMutablePointer(to: &type) {
        (zz : UnsafeMutablePointer<PyTypeObject>) -> Bool in

      let ss = tz == zz
        let gg = Int(0) != Int(PyType_IsSubtype(self.pointer.pointee.ob_type, zz))
      return ss || gg
    }
//    return q != 0
/*    var typex = type
  let typePyRef = UnsafeMutableRawPointer( &typex).assumingMemoryBound(to: PyObject.self)
*/

    // let result = Int(PyObject_IsInstance(pointer, &tx))
    // return result != 0
  }
}

extension Bool : ConvertibleFromPython {
  public init?(_ pythonObject: PythonObject) {
    pythonObject.retain()
    guard pythonObject.isType(&PyBool_Type) else { return nil }
    defer { pythonObject.release() }
    self = pythonObject.pointer != PyFalse
  }
}

extension String : ConvertibleFromPython {
  public init?(_ pythonObject: PythonObject) {
    pythonObject.retain()
    defer { pythonObject.release() }
    guard let cString = PyUnicode_AsUTF8(pythonObject.pointer) else { PyErr_Clear(); return nil }
    self.init(cString: cString)
  }
}

extension Int : ConvertibleFromPython {
  public init?(_ pythonObject: PythonObject) {
    pythonObject.retain()
    defer { pythonObject.release() }
    let value = PyLong_AsLong(pythonObject.pointer)
    if PyErr_Occurred() != nil { PyErr_Clear(); return nil }
    self = value
  }
}

extension UInt : ConvertibleFromPython {
  public init?(_ pythonObject: PythonObject) {
    pythonObject.retain()
    defer { pythonObject.release() }
    let value = PyLong_AsUnsignedLongMask(pythonObject.pointer)
    if PyErr_Occurred() != nil { PyErr_Clear(); return nil }
    self = value
  }
}

extension Double : ConvertibleFromPython {
  public init?(_ pythonObject: PythonObject) {
    pythonObject.retain()
    defer { pythonObject.release() }
    let value = PyFloat_AsDouble(pythonObject.pointer)
    if PyErr_Occurred() != nil { PyErr_Clear(); return nil }
    self = value
  }
}

extension Optional : ConvertibleFromPython where Wrapped : ConvertibleFromPython {
  public init?(_ object: PythonObject) {
    if object == Python.None {
      self = .none
    } else {
      guard let converted = Wrapped(object) else { return nil }
      self = .some(converted)
    }
  }
}

extension Array : ConvertibleFromPython where Element : ConvertibleFromPython {
  public init?(_ pythonObject: PythonObject) {
    self = []
    for elementObject in pythonObject {
      guard let element = Element(elementObject) else { return nil }
      append(element)
    }
  }
}

extension Dictionary : ConvertibleFromPython
where Key : ConvertibleFromPython, Value : ConvertibleFromPython {
  public init?(_ pythonDict: PythonObject) {
    self = [:]
    
    var key, value: PyObjectRef?
    var position: Int = 0
    
    while PyDict_Next(pythonDict.pythonObject.pointer, &position, &key, &value) != 0 {
      if let key = key, let value = value,
        let swiftKey = Key(PythonObject(retaining: key)),
        let swiftValue = Value(PythonObject(retaining: value)) {
        self[swiftKey] = swiftValue
      } else {
        return nil
      }
    }
  }
}

extension Range : ConvertibleFromPython where Bound : ConvertibleFromPython {
  public init?(_ pythonObject: PythonObject) {
    guard pythonObject.isType(&PySlice_Type) else { return nil }
    guard let lowerBound = Bound(pythonObject.start), let upperBound = Bound(pythonObject.stop) else { return nil }
    guard pythonObject.step == Python.None else { return nil }
    self.init(uncheckedBounds: (lowerBound, upperBound))
  }
}

extension PartialRangeFrom : ConvertibleFromPython where Bound : ConvertibleFromPython {
  public init?(_ pythonObject: PythonObject) {
    guard pythonObject.isType(&PySlice_Type) else { return nil }
    guard let lowerBound = Bound(pythonObject.start) else { return nil }
    guard pythonObject.stop == Python.None, pythonObject.step == Python.None else { return nil }
    self.init(lowerBound)
  }
}

extension PartialRangeUpTo : ConvertibleFromPython where Bound : ConvertibleFromPython {
  public init?(_ pythonObject: PythonObject) {
    guard pythonObject.isType(&PySlice_Type) else { return nil }
    guard let upperBound = Bound(pythonObject.stop) else { return nil }
    guard pythonObject.start == Python.None, pythonObject.step == Python.None else { return nil }
    self.init(upperBound)
  }
}

extension Data : ConvertibleFromPython {
  public init?(_ pythonObject : PythonObject) {
    guard pythonObject.isType(&PyBytes_Type) else { return nil }
    let bb = pythonObject.retained()
    let b = PyBytes_Size(bb)
    let c = PyBytes_AsString(bb)!
    self.init()
    c.withMemoryRebound(to: UInt8.self, capacity: b) {
      self.append($0, count: b )
    }
  }
}
