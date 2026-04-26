# Readme

Repo of powershell scripts, now focused on running on MacBook.

Folders          | Content
---------------- | ----------
`./NAS-scripts/` | Scripts for running on NAS ([see readme](NAS-scripts/readme.md))
`./ps_draft`     | contains script that are not production ready/in development

## Help

## Installation

location for scripts & tools:  

    `/Users/pmario/Local/tools`

## Notes

* the idea was to carve out more compute intensive work into `HelperLib` 
* marshalling data across is however challenging
* Copilot suggested to define a serialization format (using | as a separator), which increases efforts and resource consumption on both ends
