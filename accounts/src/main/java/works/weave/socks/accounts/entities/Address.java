package works.weave.socks.accounts.entities;


import org.springframework.data.annotation.Id;

public class Address {

    @Id
    private String id;

    private String number;
    private String street;
    private String city;
    private String postcode;
    private String country;

    public Address() {
    }

    public Address(String id, String number, String street, String city, String postcode, String country) {
        this.id = id;
        this.number = number;
        this.street = street;
        this.city = city;
        this.postcode = postcode;
        this.country = country;
    }

    public Address(String number, String street, String city, String postcode, String country) {
        this(null, number, street, city, postcode, country);
    }

    @Override
    public String toString() {
        return "Address{" +
                "id=" + id +
                ", number='" + number + '\'' +
                ", street='" + street + '\'' +
                ", city='" + city + '\'' +
                ", country='" + country + '\'' +
                ", postcode='" + postcode + '\'' +
                '}';
    }

    public String getNumber() {
        return number;
    }

    public void setNumber(String number) {
        this.number = number;
    }

    public String getStreet() {
        return street;
    }

    public void setStreet(String street) {
        this.street = street;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getCountry() {
        return country;
    }

    public void setCountry(String country) {
        this.country = country;
    }

    public String getPostcode() {
        return postcode;
    }

    public void setPostcode(String postcode) {
        this.postcode = postcode;
    }
}
