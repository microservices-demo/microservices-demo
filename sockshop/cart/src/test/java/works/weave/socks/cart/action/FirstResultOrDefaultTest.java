package works.weave.socks.cart.action;

import org.junit.Test;

import java.util.Arrays;
import java.util.Collections;

import static org.hamcrest.core.IsEqual.*;
import static org.junit.Assert.*;

public class FirstResultOrDefaultTest {
    @Test
    public void whenEmptyUsesDefault() {
        String defaultValue = "test";
        FirstResultOrDefault<String> CUT = new FirstResultOrDefault<>(Collections.emptyList(), () -> defaultValue);
        assertThat(CUT.get(), equalTo(defaultValue));
    }

    @Test
    public void whenNotEmptyUseFirst() {
        String testValue = "test";
        FirstResultOrDefault<String> CUT = new FirstResultOrDefault<>(Arrays.asList(testValue), () -> "nonDefault");
        assertThat(CUT.get(), equalTo(testValue));
    }

    @Test
    public void whenMultipleNotEmptyUseFirst() {
        String testValue = "test";
        FirstResultOrDefault<String> CUT = new FirstResultOrDefault<>(Arrays.asList(testValue, "test2"), () -> "nonDefault");
        assertThat(CUT.get(), equalTo(testValue));
    }
}