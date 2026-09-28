# Time Zone Aware DateTime to Text

Time Zone Aware DateTime to Text for Salesforce. A Flow action that formats a Date/Time as text in a **UTC offset** (for example `-07:00`) or a **named time zone** (for example `America/Los_Angeles`).

[![License](https://img.shields.io/badge/License-BSD_3--Clause-blue.svg)](LICENSE)
[![Salesforce API](https://img.shields.io/badge/Salesforce_API-65.0-00A1E0)](https://developer.salesforce.com)

---

## Features

- Flow action that returns one text value for a Date/Time
- UTC offsets such as `-07:00`, `+05:30`, `-7`, and `-7.5`
- Named time zones such as `America/Los_Angeles`, using that zone’s daylight-saving rules
- Optional Java date/time pattern. The default is `yyyy-MM-dd HH:mm:ss`
- **Unlocked 2GP package** — install in any org

A fixed offset does not follow daylight saving. A named time zone ID uses that zone’s rules for the instant you pass in.

---

## Quick start

1. **Install** the unlocked package ([Install](#install-package)) or [deploy from source](docs/INSTALL.md).
2. In a Flow, add the action **Format Date Time in Time Zone Offset**.
3. Set **Date Time** and **Time Zone Offset**.
4. Use **Formatted Date Time** later in the flow.

See [Flow configuration](docs/FLOW.md).

---

## Install package

**Version `0.1.1-1` (released)** · Subscriber version Id `04tgL000000VxjlQAC`

| Org | URL |
|-----|-----|
| Production | https://login.salesforce.com/packaging/installPackage.apexp?p0=04tgL000000VxjlQAC |
| Sandbox | https://test.salesforce.com/packaging/installPackage.apexp?p0=04tgL000000VxjlQAC |

```bash
sf package install --package 04tgL000000VxjlQAC --target-org <alias>
```

After install, the Flow action is **Format Date Time in Time Zone Offset** (`three_levers.FormatDateTimeOffset`).

**Deploy from source:** [docs/INSTALL.md](docs/INSTALL.md)

---

## Requirements

- Salesforce with Flow (API 65.0 source)
- No Sites or Named Credentials

---

## Development

```bash
sf org create scratch --definition-file config/project-scratch-def.json --alias tz-datetime-scratch --set-default
sf project deploy start --manifest manifest/package.xml --target-org tz-datetime-scratch --test-level RunLocalTests
```

Packaging and 2GP releases are maintained in the private [ThreeLeversDevOrg](https://github.com/jason-best/ThreeLeversDevOrg) monorepo. Source and docs: [jason-best/sf-timezone-aware-datetime-to-text](https://github.com/jason-best/sf-timezone-aware-datetime-to-text). See [docs/PACKAGING.md](docs/PACKAGING.md).

---

## License

[BSD 3-Clause](LICENSE) · Copyright Three Levers

---

## Support

Questions or consulting: [threelevers.com/contact](https://threelevers.com/contact/)
