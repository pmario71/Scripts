export AZCOPY_CRED_TYPE=Anonymous;
export AZCOPY_CONCURRENCY_VALUE=AUTO;
export HTTPS_PROXY=dummy.invalid;
export NO_PROXY=*;
export https_proxy=dummy.invalid;
export no_proxy=*;

./azcopy copy "/Users/pmario/Documents/ObsidianHome/*" "https://nasbackup16.blob.core.windows.net/backup-obsidian-home/?sv=2025-07-05&se=2025-12-09T22%3A25%3A01Z&sr=c&sp=rwl&sig=VVlgxkoRVCDWnzN5XYAqy782fC%2FpEnfu36AEO5QCuR0%3D" --overwrite=prompt --from-to=LocalBlob --blob-type Detect --follow-symlinks --check-length=true --put-md5 --follow-symlinks --disable-auto-decoding=false --list-of-files "/var/folders/l8/k1wq33tn11b910y0q14175lm0000gn/T/stg-exp-azcopy-4a833200-0dd2-4e5d-b28a-dd7e626990da.txt" --recursive --log-level=INFO;

unset AZCOPY_CRED_TYPE;
unset AZCOPY_CONCURRENCY_VALUE;
unset HTTPS_PROXY;
unset NO_PROXY;
unset https_proxy;
unset no_proxy;
