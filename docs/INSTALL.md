# Installation

## Option A — Install unlocked package (recommended)

**Version:** `0.1.1-1` (released)  
**Subscriber package version Id:** `04tgL000000VxjlQAC`

| Org type | Install URL |
|----------|-------------|
| Production | https://login.salesforce.com/packaging/installPackage.apexp?p0=04tgL000000VxjlQAC |
| Sandbox | https://test.salesforce.com/packaging/installPackage.apexp?p0=04tgL000000VxjlQAC |

CLI:

```bash
sf package install --package 04tgL000000VxjlQAC --target-org <alias>
```

No installation key. After install, add Flow action **Format Date Time in Time Zone Offset** (`three_levers.FormatDateTimeOffset`).

## Option B — Deploy from source

### Namespaced scratch org (matches package)

```bash
sf org create scratch --definition-file config/project-scratch-def.json --alias tz-datetime-scratch --set-default
sf project deploy start --manifest manifest/package.xml --target-org tz-datetime-scratch --test-level RunLocalTests
```

### Unpackaged deploy (no namespace)

Remove or omit `"namespace"` in `sfdx-project.json`, then deploy to your dev org:

```bash
sf project deploy start --manifest manifest/package.xml --target-org <alias> --test-level RunLocalTests
```

The Flow action class is `FormatDateTimeOffset`. In a subscriber org that installed the package, Flow Builder shows it only because the class, invocable method, and invocable variables are `global`.

## Post-install

Open Flow Builder and search for **Format Date Time in Time Zone Offset**. No Sites or Named Credentials.

## Upgrade

Install a newer package version from the [README](../README.md#install-package) or redeploy from source.
