//! `cargo run -p dxcontainer --example partlist -- < paths.txt`: for each container named on stdin (one path per line),
//! print `path <TAB> kind:size:offset,...` (the offset is where the part's bytes start) and whether `checksum` equals the
//! stored digest, or the reason `chunks` refuses it. A second implementation of the same listing (vkd3d's `vkd3d-dxbc -t`)
//! is compared with this output line by line.
use std::io::BufRead;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    for line in std::io::stdin().lock().lines() {
        let path = line?;
        let bytes = std::fs::read(&path)?;
        match dxcontainer::chunks(&bytes) {
            Ok(parts) => {
                let listing: Vec<String> = parts
                    .iter()
                    .map(|p| {
                        let at = p.data.as_ptr().addr().saturating_sub(bytes.as_ptr().addr());
                        format!("{}:{}:{}", String::from_utf8_lossy(&p.kind), p.data.len(), at)
                    })
                    .collect();
                let digest_ok =
                    dxcontainer::checksum(&bytes).is_some_and(|d| bytes.get(4..20) == Some(&d[..]));
                println!("{path}\t{}\tdigest_ok={digest_ok}", listing.join(","));
            }
            Err(e) => println!("{path}\tERR {e}"),
        }
    }
    Ok(())
}
