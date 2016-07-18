package works.weave.socks.accounts;


import works.weave.socks.accounts.entities.Address;
import works.weave.socks.accounts.entities.Card;

import java.security.SecureRandom;
import java.util.Arrays;
import java.util.List;

public class DataGenerator {
    static final String NUMBERS = "0123456789";
    static final String ADDRESSES =
            "54.686485,-1.229423,69,Wilson Street,Hartlepool,Hartlepool,,Hartlepool,,TS26 8JU,United Kingdom\n" +
                    "55.93475,-4.041213,5,Mossywood Road,Cumbernauld,Glasgow,,North Lanarkshire,,G68 9DX,United Kingdom\n" +
                    "52.273227,-0.894929,3,Radstone Way,Northampton,Northampton,,Northamptonshire,,NN2 8NT,United Kingdom\n" +
                    "53.546201,-2.536368,86,Dobb Brow Road,Westhoughton,Bolton,,Greater Manchester,,BL5 2BB,United Kingdom\n" +
                    "52.697129,-2.5117,25,New Church Road,Wellington,Telford,,Telford and Wrekin,,TF1 1JX,United Kingdom\n" +
                    "52.467032,-1.784443,61,Comberton Road,Birmingham,Birmingham,,West Midlands,,B26 2TE,United Kingdom\n" +
                    "51.696877,-3.425228,4,Maes-Y-Deri,Aberdare,Aberdare,,Rhondda Cynon Taff,,CF44 6TF,United Kingdom\n" +
                    "55.967787,-3.947232,246,Whitelees Road,Cumbernauld,Glasgow,,North Lanarkshire,,G67 3DL,United Kingdom\n" +
                    "53.344684,-1.775422,2,Trickett Close,Castleton,Hope Valley,,Derbyshire,,S33 8WR,United Kingdom\n" +
                    "51.991012,-1.702661,21A,High Street,Moreton-in-Marsh,Moreton-in-Marsh,,Gloucestershire,,GL56 0BJ,United Kingdom\n";
    static SecureRandom rnd = new SecureRandom();
    private List<String> addressList;

    public String randomNumberString(int len) {
        StringBuilder sb = new StringBuilder(len);
        for (int i = 0; i < len; i++)
            sb.append(NUMBERS.charAt(rnd.nextInt(NUMBERS.length())));
        return sb.toString();
    }

    public Address randomAddress() {
        String address = addresses().get(rnd.nextInt(addresses().size()));
        return new Address(number(address), street(address), city(address), postcode(address), country(address));
    }

    public Card randomCard() {
        return new Card(randomNumberString(16), "08/19", randomNumberString(3));
    }

    private List<String> addresses() {
        if (addressList == null) {
            addressList = Arrays.asList(ADDRESSES.split("\\n"));
        }
        return addressList;
    }

    private String number(String addressLine) {
        return addressLine.split(",")[2];
    }

    private String street(String addressLine) {
        return addressLine.split(",")[3];
    }

    private String city(String addressLine) {
        return addressLine.split(",")[5];
    }

    private String postcode(String addressLine) {
        return addressLine.split(",")[9];
    }

    private String country(String addressLine) {
        return addressLine.split(",")[10];
    }


}