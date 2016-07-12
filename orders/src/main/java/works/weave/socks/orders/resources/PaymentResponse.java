package works.weave.socks.orders.resources;

public class PaymentResponse {
    private boolean authorised = false;

    // For jackson
    public PaymentResponse() {
    }

    public PaymentResponse(boolean authorised) {
        this.authorised = authorised;
    }

    @Override
    public String toString() {
        return "PaymentResponse{" +
                "authorised=" + authorised +
                '}';
    }

    public boolean isAuthorised() {
        return authorised;
    }

    public void setAuthorised(boolean authorised) {
        this.authorised = authorised;
    }
}
