# Flow configuration

Add Apex action **Format Date Time in Time Zone Offset**. Each run formats one Date/Time into text.

## Action name

| Install method | Flow action |
|----------------|-------------|
| Unlocked package | **Format Date Time in Time Zone Offset** (`three_levers.FormatDateTimeOffset`) |
| Deploy from source | **Format Date Time in Time Zone Offset** (`FormatDateTimeOffset`) |

## Format a Date/Time

1. Set **Date Time**.
2. Set **Time Zone Offset** to a UTC offset or a time zone ID.
3. Leave **Date Time Format** blank to use `yyyy-MM-dd HH:mm:ss`, or set a Java date/time pattern.
4. Use **Formatted Date Time** in a later element.

A blank Date Time returns a blank Formatted Date Time and does not fault. A blank or unrecognized Time Zone Offset faults the interview. Connect a fault path when the offset can be missing or invalid.

## Inputs

| Input | Required | Notes |
|-------|----------|--------|
| Date Time | Yes | The instant to format. Salesforce Date/Time values are stored in UTC. |
| Time Zone Offset | Yes | A UTC offset or a time zone ID. See the examples below. |
| Date Time Format | No | Java date/time pattern. Default: `yyyy-MM-dd HH:mm:ss`. Example: `M/d/yyyy h:mm a`. |

## Output

| Output | Notes |
|--------|--------|
| Formatted Date Time | Text in the requested offset or time zone. Blank when Date Time is blank. |

## Offsets

A fixed offset is a constant difference from UTC. It does not change for daylight saving.

| Example | Meaning |
|---------|---------|
| `-07:00` | Seven hours behind UTC |
| `+05:30` | Five hours and thirty minutes ahead of UTC |
| `-07:00:00` | Same as `-07:00`, with seconds |
| `-7` | Seven hours behind UTC |
| `-7.5` | Seven hours and thirty minutes behind UTC |
| `UTC-08:00` | Eight hours behind UTC. `GMT` works the same way as `UTC` |
| `Z`, `UTC`, `GMT` | UTC, offset zero |

Supported offsets run from `-14:00` through `+14:00`. Minutes and seconds must be `00` through `59`.

## Named time zones

A time zone ID uses that zone’s rules for the Date Time you pass in, including daylight saving.

| Example | Use |
|---------|-----|
| `America/Los_Angeles` | Pacific Time. Standard time is UTC−8. Daylight time is UTC−7. |
| `America/New_York` | Eastern Time |
| `Europe/London` | United Kingdom time |
| `Asia/Kolkata` | India Standard Time, UTC+5:30 |

On `2026-09-27 17:00` UTC, `America/Los_Angeles` and the fixed offset `-07:00` both format as `2026-09-27 10:00:00` with the default pattern. In January that same clock time in `America/Los_Angeles` is UTC−8, while `-07:00` stays seven hours behind UTC.

An unrecognized name, such as `Pacific`, faults the action. Use an IANA time zone ID.

## Date Time Format

The pattern is a Java date/time format. Common letters:

| Letters | Meaning | Example |
|---------|---------|---------|
| `yyyy` | Year | `2026` |
| `M` or `MM` | Month | `9` or `09` |
| `d` or `dd` | Day of the month | `7` or `07` |
| `H` or `HH` | Hour, 0–23 | `15` |
| `h` or `hh` | Hour, 1–12 | `3` |
| `mm` | Minutes | `05` |
| `ss` | Seconds | `00` |
| `a` | AM or PM | `PM` |

`M/d/yyyy h:mm a` turns `2026-09-27 17:00` UTC in `America/Los_Angeles` into `9/27/2026 10:00 AM` for an English (United States) user. Month names and the AM/PM marker follow the running user’s language.

## Faults

`FormatDateTimeOffsetException` is raised when Time Zone Offset is blank, outside `-14:00` to `+14:00`, has invalid minutes or seconds, or is not a recognized time zone ID. Put a Fault path on the action when the offset comes from a field or a formula that can be wrong.
