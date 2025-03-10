use dart_sys::{
    _Dart_CObject__bindgen_ty_1, _Dart_CObject__bindgen_ty_1__bindgen_ty_5, Dart_CObject,
    Dart_CObject_Type_Dart_CObject_kExternalTypedData, Dart_InitializeApiDL, Dart_Port,
    Dart_PostCObject_DL, Dart_TypedData_Type_Dart_TypedData_kUint8,
};
use std::ffi::c_void;
use std::thread;

#[unsafe(no_mangle)]
pub unsafe extern "C" fn start_send_loop(data: *mut c_void, port: Dart_Port) -> isize {
    let res = Dart_InitializeApiDL(data);

    if res != 0 {
        return res;
    }
    thread::spawn(move || {
        let mut i = 0u64;
        loop {
            thread::sleep(std::time::Duration::from_millis(10));
            i += 1;

            let mut vec: Vec<u8> = i.to_be_bytes().to_vec();
            vec.shrink_to_fit();

            let length = vec.len() as isize;
            let data = vec.as_mut_ptr();
            let peer = Box::into_raw(Box::new(vec)) as *mut c_void;

            let mut msg = Dart_CObject {
                type_: Dart_CObject_Type_Dart_CObject_kExternalTypedData,
                value: _Dart_CObject__bindgen_ty_1 {
                    as_external_typed_data: _Dart_CObject__bindgen_ty_1__bindgen_ty_5 {
                        type_: Dart_TypedData_Type_Dart_TypedData_kUint8,
                        length,
                        data,
                        peer,
                        callback: Some(reclaim_vec_cb),
                    },
                },
            };

            if !Dart_PostCObject_DL.unwrap()(port, &mut msg) {
                println!("Dart_PostCObject_DL == false for {peer:p}, so cleaning from native code");
                msg.value.as_external_typed_data.callback.as_ref().unwrap()(
                    msg.value.as_external_typed_data.data.cast(),
                    msg.value.as_external_typed_data.peer,
                );
            }
        }
    });

    res
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn reclaim_vec_cb(_isolate_callback_data: *mut c_void, peer: *mut c_void) {
    println!("reclaim_cb {peer:p}");
    Box::from_raw(peer.cast::<Vec<u8>>());
}
