package com.contentwise.janus.serializer;

import com.contentwise.janus.serializer.LinkedHashMapSerializer;
import org.janusgraph.diskstorage.ReadBuffer;
import org.janusgraph.graphdb.database.serialize.DataOutput;
import org.janusgraph.graphdb.database.serialize.StandardSerializer;
import org.junit.Test;

import java.util.LinkedHashMap;

import static org.junit.Assert.*;

public class LinkedHashMapSerializerTest {

    private StandardSerializer getStandardSerializer() {
        // register the custom attribute serializer with the Titan standard serializer
        StandardSerializer serialize = new StandardSerializer();
        serialize.registerClass(2, LinkedHashMap.class, new LinkedHashMapSerializer());
        assertTrue(serialize.validDataType(LinkedHashMap.class));
        return serialize;
    }

    @Test
    public void writeReadObjectNotNull() {
        StandardSerializer serialize = getStandardSerializer();

        // use the serializer to write the object
        LinkedHashMap<String,Integer> map = new LinkedHashMap<String,Integer>();
        map.put("one",1);
        DataOutput out = serialize.getDataOutput(128);
        out.writeObjectNotNull(map);

        // use the serializer to read the object
        ReadBuffer b = out.getStaticBuffer().asReadBuffer();
        LinkedHashMap<String,Integer> read = (LinkedHashMap<String,Integer>) serialize.readObjectNotNull(b, LinkedHashMap.class);

        // make sure they are equal
        assertEquals(map.size(), read.size());
        assertEquals(map.get("one"), read.get("one"));
    }

    @Test
    public void writeReadClassAndObject() {
        StandardSerializer serialize = getStandardSerializer();

        // use the serializer to write the object
        LinkedHashMap<String,Integer> map = new LinkedHashMap<String,Integer>();
        map.put("one",1);
        DataOutput out = serialize.getDataOutput(128);
        out.writeClassAndObject(map);

        // use the serializer to read the object
        ReadBuffer b = out.getStaticBuffer().asReadBuffer();
        LinkedHashMap<String,Integer> read = (LinkedHashMap<String,Integer>) serialize.readClassAndObject(b);

        // make sure they are equal
        assertEquals(map.size(), read.size());
        assertEquals(map.get("one"), read.get("one"));
    }

    @Test
    public void writeReadObject() {
        StandardSerializer serialize = getStandardSerializer();

        // use the serializer to write the object
        LinkedHashMap<String,Integer> map = new LinkedHashMap<String,Integer>();
        map.put("one",1);
        DataOutput out = serialize.getDataOutput(128);
        out.writeObject(map, LinkedHashMap.class);

        // use the serializer to read the object
        ReadBuffer b = out.getStaticBuffer().asReadBuffer();
        LinkedHashMap<String,Integer> read = (LinkedHashMap<String,Integer>) serialize.readObject(b, LinkedHashMap.class);

        // make sure they are equal
        assertEquals(map.size(), read.size());
        assertEquals(map.get("one"), read.get("one"));
    }

}