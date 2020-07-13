---
page_title: "Nebula"
---

[![Build Status](https://git.bink.com/DevOps/Cookbooks/nebula/badges/master/pipeline.svg)](https://git.bink.com/DevOps/Cookbooks/nebula)

## Hardening

The nebula cookbook performs generic Ubuntu hardening based on the CIS guidelines. The cookbook specifically ignores the CIS networking section as those tweaks cause instability when operating Kubernetes as well as being less relevant when operating in a cloud envrionment.

The OpenSSH server config is also hardened, the config is rather verbose including defaults purely so that we can use tools like Inspec to validate the setup.

### CIS Information

TODO list specific controls that have been skipped

## Verification

This cookbook installs Inspec with a Python 3.5 runner script which runs Inspec, collected the JSON output, simpiflies the results and then submits to Elasticsearch. This runs daily at 4AM configured by a systemd timer `inspec.timer` and `inspec.service`.

A base Inspec profile is deployed (look in `./files/base`) which is an Inspec YAML file declaring dependencies and Inspec controls which currently only trigger the depenencies to run (just declaring dependencies will not actually trigger them to run). Currently the Python shim will only run the baseline profile, but it will eventually be updated to run all profiles in a directory (it seems at the moment Inspec needs to be provided a list of profiles to run).

The [Linux baseline](https://github.com/dev-sec/linux-baseline) and [SSH baseline](https://github.com/dev-sec/ssh-baseline) Inspec profiles are pulled from their respective GitHub repositories and ran againt the host system, various controls have been skipped for the reasons discussed above.

### Inspec result format

The JSON document below will be sent to elasticsearch for each profile ran against the host, currently they will be `linux-baseline` and `ssh-baseline`. The document is a summary of the profile run, with the aim of making a Grafana compliance dashboard easier. These documents will appear under the `inspec-summary-YYYY-MM-DD` indicies.
```json
{
    "@timestamp": "2020-07-09T11:38:24Z",
    "inspec_profile": "linux-baseline",
    "host": "C02CCHDGMD6M",
    "ip": "127.0.0.1",
    "success_percentange": 0.99
}
```

Inspec results are more verbose and repeated for every inspec control that passed or failed. These documents combined with the summaries should provide enough data in Elasticsearch to allow a Grafana dashboard to drill down into results and display some sane information. These documents will appear under the `inspec-results-YYYY-MM-DD` indicies.
```json
{
    "control_id": "os-05",
    "control_title": "Check login.defs",
    "status": "passed",
    "@timestamp": "2020-07-09T16:01:26+00:00",
    "name": "linux-baseline",
    "title": "DevSec Linux Security Baseline",
    "version": "2.4.5",
    "host": "bastion",
    "ip": "192.168.4.4"
}
```

## Cookbook Updates

Currently the cookbook pulls version `4.21.3-1` of Inspec. Whilst there is not a direct need to keep this up to date, it would make sense to check this biannually. 
