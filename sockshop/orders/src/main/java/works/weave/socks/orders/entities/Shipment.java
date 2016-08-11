package works.weave.socks.orders.entities;

import java.util.UUID;

public class Shipment {
    private String id;
    private String name;

    public Shipment() {
        this("");
    }

    public Shipment(String name) {
        this(UUID.randomUUID().toString(), name);
    }

    public Shipment(String id, String name) {
        this.id = id;
        this.name = name;
    }

    @Override
    public String toString() {
        return "Shipment{" +
                "id='" + id + '\'' +
                ", name='" + name + '\'' +
                '}';
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        Shipment shipment = (Shipment) o;

        return getId() != null ? getId().equals(shipment.getId()) : shipment.getId() == null;

    }

    @Override
    public int hashCode() {
        return getId() != null ? getId().hashCode() : 0;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}
