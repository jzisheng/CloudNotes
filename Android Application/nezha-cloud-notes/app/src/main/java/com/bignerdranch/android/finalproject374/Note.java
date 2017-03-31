package com.bignerdranch.android.finalproject374;

/**
 * Created by Jason on 11/30/2016.
 */
public class Note {
    private String objectid;
    private String note;

    public Note(String objectid, String note) {
        this.objectid = objectid;
        this.note = note;
    }

    public void setNote(String note){
        this.note = note;
    }

    public void setObjectId(String objectId){
        this.objectid = objectId;
    }

    public String getNote() {
        return note;
    }

    public String getObjectid(){
        return objectid;
    }

    @Override
    public String toString() {
        return objectid+" "+note;
    }

}
