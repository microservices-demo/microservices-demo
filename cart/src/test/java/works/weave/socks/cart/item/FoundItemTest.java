package works.weave.socks.cart.item;

import org.junit.Test;
import works.weave.socks.cart.entities.Item;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.core.IsEqual.equalTo;
import static org.junit.Assert.assertThat;

public class FoundItemTest {
    private ItemDAO itemDAO = new ItemDAO.Fake();

    @Test
    public void findOneItem() {
        String testId = "testId";
        Item testAnswer = new Item();
        testAnswer.itemId = testId;
        itemDAO.save(testAnswer);
        FoundItem foundItem = new FoundItem(itemDAO, testId);
        assertThat(foundItem.get(), is(equalTo(testAnswer)));
    }
}