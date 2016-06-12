package works.weave.socks.cart.item;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mock;
import org.mockito.runners.MockitoJUnitRunner;
import works.weave.socks.cart.controllers.ItemsController;
import works.weave.socks.cart.entities.Item;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.core.IsEqual.equalTo;
import static org.junit.Assert.assertThat;
import static org.mockito.Mockito.when;

@RunWith(MockitoJUnitRunner.class)
public class GetItemTest {

    @Mock
    private ItemsController controller;

    @Test
    public void testGetItemWithString() {
        String itemId = "itemId";
        Item item = new Item();
        when(controller.get(itemId)).thenReturn(item);
        GetItem getItem = new GetItem(controller, itemId);
        assertThat(getItem.get(), is(equalTo(item)));
    }

    @Test
    public void testGetItemWithItem() {
        String itemId = "itemId";
        Item item = new Item();
        item.itemId = itemId;
        when(controller.get(itemId)).thenReturn(item);
        GetItem getItem = new GetItem(controller, item);
        assertThat(getItem.get(), is(equalTo(item)));
    }
}