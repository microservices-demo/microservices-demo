package works.weave.socks.cart.item;

import org.junit.Test;
import works.weave.socks.cart.entities.Item;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.Matchers.nullValue;
import static org.hamcrest.core.IsEqual.equalTo;
import static org.junit.Assert.assertThat;


public class ItemResourceTest {
    private ItemDAO itemDAO = new ItemDAO.Fake();

    @Test
    public void testCreateAndDestroy() {
        Item item = new Item();
        String testId = "testId";
        item.itemId = testId;
        ItemResource itemResource = new ItemResource(itemDAO, () -> item);
        itemResource.create().run();
        assertThat(itemDAO.findOne(testId), is(equalTo(item)));
        itemResource.destroy().run();
        assertThat(itemDAO.findOne(testId), is(nullValue()));
    }

    @Test
    public void whenViewedShouldCreateIfNotExist() {
        Item item = new Item();
        String testId = "testId";
        item.itemId = testId;
        ItemResource itemResource = new ItemResource(itemDAO, () -> item);
        assertThat(itemDAO.findOne(testId), is(nullValue()));
        assertThat(itemResource.value().get(), is(equalTo(item)));
        assertThat(itemDAO.findOne(testId), is(equalTo(item)));
    }

    @Test
    public void mergedItemShouldHaveNewQuantity() {
        Item item = new Item();
        String testId = "testId";
        item.itemId = testId;
        item.quantity = 1;
        ItemResource itemResource = new ItemResource(itemDAO, () -> item);
        assertThat(itemResource.value().get(), is(equalTo(item)));
        Item newItem = new Item();
        newItem.itemId = testId;
        int testQuantity = 10;
        newItem.quantity = testQuantity;
        itemResource.merge(newItem).run();
        assertThat(itemResource.value().get().quantity, is(equalTo(testQuantity)));
    }
}