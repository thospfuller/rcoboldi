package com.coherentlogic.rproject.integration.rcobol.api;

public interface IUpdateFieldName {

    /**
     * Convert Cobol/RecordEditor Name to standard name
     *
     * @param name current field name
     *
     * @return new name
     */
    String updateName(String name);
}
