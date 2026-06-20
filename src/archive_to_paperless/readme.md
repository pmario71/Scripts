# Archive-to-paperless Readme

```
Usage: archive_to_paperless <file1> [file2 ...]
Copies files to the NAS drop folder and archives them locally.

Arguments:
  <file1> [file2 ...]   One or more files to process.

Options:
  -h, --help            Show this help message and exit.

NAS Drop Path: /Volumes/dropfolders/paperless
Archive Path:  /Users/pmario/Local/archived
```

## Todo

* [ ] Support overriding the default paths for `paperless dropfolder` and `archive folder` through json appsettings.configuration