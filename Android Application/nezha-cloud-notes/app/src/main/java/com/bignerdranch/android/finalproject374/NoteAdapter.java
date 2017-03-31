package com.bignerdranch.android.finalproject374;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import java.util.ArrayList;

/**
 * Created by Jason on 11/30/2016.
 */

public class NoteAdapter extends ArrayAdapter<Note> {
    public NoteAdapter(Context context, ArrayList<Note> notes) {
        super(context, 0, notes);
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        // Get the data item for this position
        Note note = getItem(position);
        // Check if an existing view is being reused, otherwise inflate the view
        if (convertView == null) {
            convertView = LayoutInflater.from(getContext()).inflate(R.layout.item_note, parent, false);
        }
        // Lookup view for data population
        TextView textViewNote = (TextView) convertView.findViewById(R.id.textview_note);
        // Populate the data into the template view using the data object
        textViewNote.setText(note.getNote());
        // Return the completed view to render on screen
        return convertView;
    }
}