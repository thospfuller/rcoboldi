package com.coherentlogic.rproject.integration.rcoboldi.api;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertThrows;

public class JCopyBookConverterTest {

//    @BeforeEach
//    public void setUp () {
//
//    }
//
//    @AfterEach
//    public void tearDown () {
//
//    }

    @Test
    public void testGetFileStructureWithInvalidFS() {
        assertThrows (
            UnrecognizedFileStructureRuntimeException.class,
            () -> {
                JCopyBookConverter.getFileStructure("blah!");
            }
        );
    }
}