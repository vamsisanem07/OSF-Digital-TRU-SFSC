public with sharing class Luhn {

    /**
    * This method used for generating R-club card number checksum. See Luhn algorithm.
    * @param ccNumberWithoutCheckDigit String
    * @return Integer.
    */
    public static Integer generateChecksum(String ccNumberWithoutCheckDigit){
        Integer sum = 0;
        Integer len = ccNumberWithoutCheckDigit.length();

        for(Integer i = len - 1; i >= 0; i--){
            sum += doubleDigit(ccNumberWithoutCheckDigit, i, len);
        }

        return calculateCheckDigit(sum);
    }

    /**
    * This method used for doubling every second digit. See Luhn algorithm.
    * @param ccNumberWithoutCheckDigit String
    * @param index Integer
    * @param len Integer
    * @return Integer.
    */
    @TestVisible
    private static Integer doubleDigit(String ccNumberWithoutCheckDigit, Integer index, Integer len){
        Integer num = Integer.ValueOf(ccNumberWithoutCheckDigit.substring(index, index + 1));

        if (math.mod(index , 2) == math.mod(len, 2)) {
            return num;
        } else {
            Integer n = num * 2;
            return (n / 10) + (math.mod(n, 10));
        }
    }

    /**
    * This method used for calculating check digit. See Luhn algorithm.
    * @param sum String
    * @return Integer.
    */
    @TestVisible
    private static Integer calculateCheckDigit(Integer sum){
        return math.mod(sum, 10) == 0 ? 0 : math.mod((sum * 9), 10);
    }
}