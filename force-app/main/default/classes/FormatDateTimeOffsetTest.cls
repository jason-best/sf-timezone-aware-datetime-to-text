@IsTest
private class FormatDateTimeOffsetTest {

    @IsTest
    static void testNegativeColonOffset() {
        FormatDateTimeOffset.FormatDateTimeOffsetInput input = inputFor(
            Datetime.newInstanceGmt(2026, 9, 24, 22, 30, 0),
            '-07:00',
            null
        );

        List<FormatDateTimeOffset.FormatDateTimeOffsetOutput> results = format(input);

        System.assertEquals(1, results.size());
        System.assertEquals('2026-09-24 15:30:00', results[0].formattedDateTime);
    }

    @IsTest
    static void testPositiveOffsetCrossesMidnight() {
        FormatDateTimeOffset.FormatDateTimeOffsetInput input = inputFor(
            Datetime.newInstanceGmt(2026, 9, 24, 22, 30, 0),
            '+05:30',
            null
        );

        List<FormatDateTimeOffset.FormatDateTimeOffsetOutput> results = format(input);

        System.assertEquals('2026-09-25 04:00:00', results[0].formattedDateTime);
    }

    @IsTest
    static void testDecimalHourOffsetAndPrefixes() {
        Datetime value = Datetime.newInstanceGmt(2026, 9, 24, 22, 30, 0);

        System.assertEquals('2026-09-24 15:00:00', formatOne(value, '-7.5', null));
        System.assertEquals('2026-09-24 15:00:00', formatOne(value, 'UTC-7.5', null));
        System.assertEquals('2026-09-24 15:30:00', formatOne(value, 'UTC -07:00', null));
        System.assertEquals('2026-09-24 14:30:00', formatOne(value, 'GMT-08:00', null));
        System.assertEquals('2026-09-25 03:30:00', formatOne(value, 'UTC+5', null));
        System.assertEquals('2026-09-24 22:30:00', formatOne(value, 'Z', null));
        System.assertEquals('2026-09-24 22:30:00', formatOne(value, 'UTC', null));
        System.assertEquals('2026-09-24 22:30:00', formatOne(value, '0', null));
    }

    @IsTest
    static void testCustomFormatAndMaxOffset() {
        Datetime value = Datetime.newInstanceGmt(2026, 1, 1, 0, 0, 0);

        System.assertEquals('2026-09-24 15:30', formatOne(
            Datetime.newInstanceGmt(2026, 9, 24, 22, 30, 0),
            '-07:00',
            'yyyy-MM-dd HH:mm'
        ));
        System.assertEquals('2026-01-01 14:00:00', formatOne(value, '+14:00', null));
    }

    @IsTest
    static void testNamedTimeZoneFollowsDaylightSaving() {
        Datetime summer = Datetime.newInstanceGmt(2026, 7, 15, 19, 0, 0);
        Datetime winter = Datetime.newInstanceGmt(2026, 1, 15, 20, 0, 0);

        System.assertEquals('2026-07-15 12:00:00', formatOne(summer, 'America/Los_Angeles', null));
        System.assertEquals('2026-07-15 12:00:00', formatOne(summer, '-07:00', null));
        System.assertEquals('2026-01-15 12:00:00', formatOne(winter, 'America/Los_Angeles', null));
        System.assertEquals('2026-01-15 12:00:00', formatOne(winter, '-08:00', null));
        System.assertEquals('2026-01-15 13:00:00', formatOne(winter, '-07:00', null));
    }

    @IsTest
    static void testNullDateTimeAndBulkInputs() {
        FormatDateTimeOffset.FormatDateTimeOffsetInput blank = inputFor(null, '-07:00', null);
        FormatDateTimeOffset.FormatDateTimeOffsetInput second = inputFor(
            Datetime.newInstanceGmt(2026, 9, 24, 22, 30, 0),
            '+05:30',
            null
        );

        Test.startTest();
        List<FormatDateTimeOffset.FormatDateTimeOffsetOutput> results = FormatDateTimeOffset.formatDateTime(
            new List<FormatDateTimeOffset.FormatDateTimeOffsetInput>{ blank, second }
        );
        Test.stopTest();

        System.assertEquals(2, results.size());
        System.assertEquals(null, results[0].formattedDateTime);
        System.assertEquals('2026-09-25 04:00:00', results[1].formattedDateTime);
    }

    @IsTest
    static void testInvalidOffsets() {
        Datetime value = Datetime.newInstanceGmt(2026, 9, 24, 22, 30, 0);
        assertThrows(value, null, 'required');
        assertThrows(value, '   ', 'required');
        assertThrows(value, 'not-a-zone', 'not recognized');
        assertThrows(value, '+15:00', 'outside the supported range');
        assertThrows(value, '+05:60', 'invalid minutes');
    }

    private static FormatDateTimeOffset.FormatDateTimeOffsetInput inputFor(Datetime value, String offset, String formatPattern) {
        FormatDateTimeOffset.FormatDateTimeOffsetInput input = new FormatDateTimeOffset.FormatDateTimeOffsetInput();
        input.dateTimeValue = value;
        input.timeZoneOffset = offset;
        input.dateTimeFormat = formatPattern;
        return input;
    }

    private static List<FormatDateTimeOffset.FormatDateTimeOffsetOutput> format(FormatDateTimeOffset.FormatDateTimeOffsetInput input) {
        return FormatDateTimeOffset.formatDateTime(
            new List<FormatDateTimeOffset.FormatDateTimeOffsetInput>{ input }
        );
    }

    private static String formatOne(Datetime value, String offset, String formatPattern) {
        return format(inputFor(value, offset, formatPattern))[0].formattedDateTime;
    }

    private static void assertThrows(Datetime value, String offset, String messageFragment) {
        Boolean threw = false;
        try {
            formatOne(value, offset, null);
        } catch (FormatDateTimeOffsetException e) {
            threw = true;
            System.assert(e.getMessage().contains(messageFragment), e.getMessage());
        }
        System.assert(threw, 'Expected FormatDateTimeOffsetException for offset: ' + offset);
    }
}
