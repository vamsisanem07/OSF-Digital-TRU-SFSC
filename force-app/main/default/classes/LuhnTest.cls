@IsTest
private class LuhnTest {
    @IsTest
    static void generateChecksumTest() {
        String ccNumberWithoutCheckDigit = '7992739871';

        Test.startTest();
        Integer result = Luhn.generateChecksum(ccNumberWithoutCheckDigit);
        Test.stopTest();

        System.assertEquals(3, result);
    }

    @IsTest
    static void doubleDigitOddDigitTest() {
        String ccNumberWithoutCheckDigit = '1234';
        Integer len = ccNumberWithoutCheckDigit.length();

        Test.startTest();
        Integer result = Luhn.doubleDigit(ccNumberWithoutCheckDigit, 3, len);
        Test.stopTest();

        System.assertEquals(8, result);
    }

    @IsTest
    static void doubleDigitEvenDigitTest() {
        String ccNumberWithoutCheckDigit = '1234';
        Integer len = ccNumberWithoutCheckDigit.length();

        Test.startTest();
        Integer result = Luhn.doubleDigit(ccNumberWithoutCheckDigit, 2, len);
        Test.stopTest();

        System.assertEquals(3, result);
    }

    @IsTest
    static void calculateCheckDigitTest() {
        Test.startTest();
        Integer result = Luhn.calculateCheckDigit(22);
        Test.stopTest();

        System.assertEquals(8, result);
    }

    @IsTest
    static void calculateCheckDigitNegativeTest() {
        Test.startTest();
        Integer result = Luhn.calculateCheckDigit(20);
        Test.stopTest();

        System.assertEquals(0, result);
    }
}