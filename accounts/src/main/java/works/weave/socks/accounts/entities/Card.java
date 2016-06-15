package works.weave.socks.accounts.entities;

import org.springframework.data.annotation.Id;

import java.math.BigInteger;

public class Card {

    @Id
    private BigInteger id;

    private String longNum;
    private String expires;
    private String ccv;

    @Override
    public String toString() {
        return "Card{" +
                "id=" + id +
                ", longNum='" + longNum + '\'' +
                ", expires='" + expires + '\'' +
                ", ccv='" + ccv + '\'' +
                '}';
    }

    public String getLongNum() {
        return longNum;
    }

    public void setLongNum(String longNum) {
        this.longNum = longNum;
    }

    public String getExpires() {
        return expires;
    }

    public void setExpires(String expires) {
        this.expires = expires;
    }

    public String getCcv() {
        return ccv;
    }

    public void setCcv(String ccv) {
        this.ccv = ccv;
    }
}
