/**
 * Invocable action: format a Date/Time as text in a fixed UTC offset or a named time zone.
 * A fixed offset (for example -07:00 or -7.5) does not follow daylight saving.
 * A time zone ID (for example America/Los_Angeles) uses that zone's rules for the given instant.
 */
global with sharing class FormatDateTimeOffset {

    private static final Integer MAX_OFFSET_SECONDS = 14 * 60 * 60;
    private static final String DEFAULT_FORMAT = 'yyyy-MM-dd HH:mm:ss';
    private static final Pattern COLON_OFFSET = Pattern.compile('^([+-])?(\\d{1,2}):(\\d{2})(?::(\\d{2}))?$');
    private static final Pattern HOUR_OFFSET = Pattern.compile('^([+-])?(\\d{1,2})(?:\\.(\\d+))?$');

    global class FormatDateTimeOffsetInput {
        @InvocableVariable(
            required=true
            label='Date Time'
            description='Date/time to format. The instant is converted into the requested offset or time zone.'
        )
        global Datetime dateTimeValue;

        @InvocableVariable(
            required=true
            label='Time Zone Offset'
            description='UTC offset such as -07:00, +05:30, -7, or -7.5, or a time zone ID such as America/Los_Angeles. UTC and GMT prefixes are accepted.'
        )
        global String timeZoneOffset;

        @InvocableVariable(
            required=false
            label='Date Time Format'
            description='Java date/time pattern. Default is yyyy-MM-dd HH:mm:ss. Example: M/d/yyyy h:mm a.'
        )
        global String dateTimeFormat;
    }

    global class FormatDateTimeOffsetOutput {
        @InvocableVariable(
            label='Formatted Date Time'
            description='Date/time text in the requested offset or time zone. Blank when Date Time is blank.'
        )
        global String formattedDateTime;
    }

    private class ResolvedZone {
        public Integer offsetSeconds;
        public String timeZoneId;
    }

    @InvocableMethod(
        label='Format Date Time in Time Zone Offset'
        description='Formats a date/time as text in a UTC offset (for example -07:00) or a time zone ID (for example America/Los_Angeles).'
    )
    global static List<FormatDateTimeOffsetOutput> formatDateTime(List<FormatDateTimeOffsetInput> inputs) {
        List<FormatDateTimeOffsetOutput> outputs = new List<FormatDateTimeOffsetOutput>();
        if (inputs == null) {
            return outputs;
        }
        for (FormatDateTimeOffsetInput input : inputs) {
            FormatDateTimeOffsetOutput output = new FormatDateTimeOffsetOutput();
            output.formattedDateTime = formatValue(
                input == null ? null : input.dateTimeValue,
                input == null ? null : input.timeZoneOffset,
                input == null ? null : input.dateTimeFormat
            );
            outputs.add(output);
        }
        return outputs;
    }

    private static String formatValue(Datetime value, String timeZoneOffset, String dateTimeFormat) {
        if (value == null) {
            return null;
        }
        String pattern = String.isBlank(dateTimeFormat) ? DEFAULT_FORMAT : dateTimeFormat;
        ResolvedZone zone = resolveZone(timeZoneOffset);
        if (zone.timeZoneId != null) {
            return value.format(pattern, zone.timeZoneId);
        }
        return value.addSeconds(zone.offsetSeconds).formatGmt(pattern);
    }

    private static ResolvedZone resolveZone(String timeZoneOffset) {
        if (String.isBlank(timeZoneOffset)) {
            throw new FormatDateTimeOffsetException('Time zone offset is required.');
        }
        String trimmed = timeZoneOffset.trim();
        Integer offsetSeconds = tryParseOffsetSeconds(trimmed);
        ResolvedZone zone = new ResolvedZone();
        if (offsetSeconds != null) {
            if (Math.abs(offsetSeconds) > MAX_OFFSET_SECONDS) {
                throw new FormatDateTimeOffsetException(
                    'Time zone offset "' + trimmed + '" is outside the supported range of -14:00 to +14:00.'
                );
            }
            zone.offsetSeconds = offsetSeconds;
            return zone;
        }
        TimeZone tz = TimeZone.getTimeZone(trimmed);
        if (tz.getID() == 'GMT') {
            throw new FormatDateTimeOffsetException(
                'Time zone offset "' + trimmed + '" is not recognized. Use an offset such as -07:00, +05:30, or -7, or a time zone ID such as America/Los_Angeles.'
            );
        }
        zone.timeZoneId = tz.getID();
        return zone;
    }

    /**
     * @return offset in seconds, 0 for UTC, or null when the value is not a numeric offset.
     */
    private static Integer tryParseOffsetSeconds(String raw) {
        String value = raw.trim().toUpperCase();
        if (value == 'Z' || value == 'UTC' || value == 'GMT') {
            return 0;
        }
        if (value.startsWith('UTC')) {
            value = value.substring(3).trim();
        } else if (value.startsWith('GMT')) {
            value = value.substring(3).trim();
        }
        if (String.isBlank(value)) {
            return 0;
        }
        value = value.replace(' ', '');

        Matcher colonMatcher = COLON_OFFSET.matcher(value);
        if (colonMatcher.matches()) {
            Integer minutes = Integer.valueOf(colonMatcher.group(3));
            Integer seconds = colonMatcher.group(4) == null ? 0 : Integer.valueOf(colonMatcher.group(4));
            if (minutes > 59 || seconds > 59) {
                throw new FormatDateTimeOffsetException(
                    'Time zone offset "' + raw + '" has invalid minutes or seconds. Use HH:mm, for example -07:00 or +05:30.'
                );
            }
            Integer sign = colonMatcher.group(1) == '-' ? -1 : 1;
            Integer hours = Integer.valueOf(colonMatcher.group(2));
            return sign * ((hours * 3600) + (minutes * 60) + seconds);
        }

        Matcher hourMatcher = HOUR_OFFSET.matcher(value);
        if (!hourMatcher.matches()) {
            return null;
        }
        Integer sign = hourMatcher.group(1) == '-' ? -1 : 1;
        Integer wholeHours = Integer.valueOf(hourMatcher.group(2));
        Integer totalSeconds = wholeHours * 3600;
        if (hourMatcher.group(3) != null) {
            Decimal fractionalHours = Decimal.valueOf('0.' + hourMatcher.group(3));
            totalSeconds += (fractionalHours * 3600).setScale(0, System.RoundingMode.HALF_UP).intValue();
        }
        return sign * totalSeconds;
    }
}
