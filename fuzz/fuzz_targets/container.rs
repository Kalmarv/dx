//! The container reader on any bytes: no panic, and bytes it accepts are what the writer writes for what it read.
#![no_main]
use libfuzzer_sys::fuzz_target;

fuzz_target!(|data: &[u8]| {
    let _ = dxcontainer::checksum(data);
    let _ = dxcontainer::feature_flags(data);
    if let Ok(parts) = dxcontainer::chunks(data) {
        let mut expected = data.to_vec();
        dxcontainer::repair_digest(&mut expected).expect("an accepted container takes a digest");
        assert_eq!(
            dxcontainer::serialize(&parts).expect("accepted parts are written"),
            expected
        );
    }
});
