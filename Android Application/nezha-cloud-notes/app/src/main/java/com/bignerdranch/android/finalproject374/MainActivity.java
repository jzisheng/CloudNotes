package com.bignerdranch.android.finalproject374;

import android.app.Activity;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import com.parse.FindCallback;
import com.parse.GetCallback;
import com.parse.Parse;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;
import com.parse.SaveCallback;

import java.util.ArrayList;
import java.util.List;


public class MainActivity extends AppCompatActivity implements SwipeRefreshLayout.OnRefreshListener {
    private Button mSaveNoteButton;
    private EditText mNoteEditText;
    private Button mLogoutButton;

    // Logging tag
    String TAG = "NOTESLOG";

    NoteAdapter itemsAdapter;
    ListView listView;

    String parseUserID;
    ParseUser mUser;

    ArrayList<Note> notes = new ArrayList<Note>();
    private SwipeRefreshLayout mSwipeRefreshLayout;

    @Override
    public void onRefresh(){
        Toast.makeText(this, "Refresh", Toast.LENGTH_SHORT).show();
        query();
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {

                mSwipeRefreshLayout.setRefreshing(false);
            }

        }, 2000);
    }

    public static void hideSoftKeyboard(Activity activity) {
        InputMethodManager inputMethodManager =
                (InputMethodManager) activity.getSystemService(
                        Activity.INPUT_METHOD_SERVICE);
        inputMethodManager.hideSoftInputFromWindow(
                activity.getCurrentFocus().getWindowToken(), 0);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Initialize Parse //
        try {
            Parse.initialize(new Parse.Configuration.Builder(this)
                    .applicationId("e9274DMCm9201")
                    .server("http://23.253.48.144:1337/parse")
                    .build()
            );
        } catch(Exception e){ }

        setContentView(R.layout.activity_main);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);

        mUser = ParseUser.getCurrentUser();
        if(mUser != null){
            // User is logged in
            mUser = ParseUser.getCurrentUser();
            Log.i("user objectId",String.valueOf(mUser.getObjectId()) );
            parseUserID = String.valueOf(mUser.getObjectId());

        } else{
            // Go back to login screen
            logout();
        }


        // Initialize and setOnClickListener for add note button
        mSaveNoteButton = (Button) findViewById(R.id.add_note_button);
        mSaveNoteButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // Add note function called, run addNote function
                addNote(null, mNoteEditText.getText().toString());
            }
        });

        // Initialize edittext field for edittext note
        mNoteEditText = (EditText) findViewById(R.id.add_note_edit_text);

        // Set onclicklistener for logout action
        mLogoutButton = (Button) findViewById(R.id.logout_button);
        mLogoutButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                ParseUser.logOut();
                logout();
            }
        });

        setSupportActionBar(toolbar);
        setUpListView();

        mSwipeRefreshLayout = (SwipeRefreshLayout) findViewById(R.id.swiperefresh);
        mSwipeRefreshLayout.setOnRefreshListener(this);

        // Query all the previous notes
        Log.i("notes array oncreate",notes.toString());

    }

    @Override
    public void onResume(){
        super.onResume();
        query();
    }

    public void deleteNote(Note note){
        ParseObject.createWithoutData("Cloudnotes",note.getObjectid()).deleteEventually();
    }

    public void setUpListView(){
        //Set up the list view with the array adapter
        itemsAdapter = new NoteAdapter(this, notes);
        //itemsAdapter = new NoteAdapter<>(this, android.R.layout.simple_list_item_1, notes);

        listView = (ListView) findViewById(R.id.notes_list_view);
        listView.setAdapter(itemsAdapter);

        listView.setOnItemLongClickListener(new AdapterView.OnItemLongClickListener() {
            @Override
            public boolean onItemLongClick(AdapterView<?> av, View v, final int pos, long id) {
                Log.i("You Click", String.valueOf(id));

                AlertDialog.Builder builder = new AlertDialog.Builder(MainActivity.this);
                builder.setMessage(R.string.delete_message)
                        .setPositiveButton(R.string.action_confirm, new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int id) {
                                Log.i("Note Removed", notes.get(pos).toString());
                                deleteNote(notes.get(pos));
                                notes.remove(pos);
                                itemsAdapter.notifyDataSetChanged();
                            }
                        })
                        .setNegativeButton(R.string.action_cancel, new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int id) {
                                // User cancelled the dialog
                            }
                        });
                builder.show();
                return true;

            }
        }
        );
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    public void logout(){
        notes.clear();
        Intent intent = new Intent(this, LoginRegistration.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(intent);
    }

    public void query(){
        notes.clear();
        Log.i("notes array onresume",notes.toString());
        ParseQuery<ParseObject> query = ParseQuery.getQuery("Cloudnotes");
        query.findInBackground(new FindCallback<ParseObject>() {
            public void done(List<ParseObject> notes, ParseException e) {
                if (e == null) {
                    //Log.d("score", "Retrieved " + notes.size() + " scores");
                    for (ParseObject object : notes){
                        //Log.i("FindInBackgroundUser", String.valueOf(object.get("userId")));
                        if(String.valueOf(object.get("userId")).equals(parseUserID)){
                            Log.i("notes array fetch", String.valueOf(object.getObjectId())+" "+String.valueOf(object.get("note")) );
                            addNote( String.valueOf(object.getObjectId()), String.valueOf(object.get("note")));
                        }
                    }
                } else {
                    Log.d("score", "Error: " + e.getMessage());
                }
            }
        });
    }

    public void addNote(String objectId, String note){
        if (note.length() != 0) {
            if(objectId == null) {
                final ParseObject newNote = new ParseObject("Cloudnotes");
                final String newNoteObjectId;

                newNote.put("note", note);
                newNote.put("userId", parseUserID);

                // Create a new note object for local storage, and prepare to store objectid
                final Note newLocalNote = new Note(null, note);

                //newNote.saveInBackground();
                // Callback to get new note's callback
                newNote.saveInBackground(new SaveCallback() {
                    public void done(ParseException e) {
                        if (e == null) {
                            // Note saved successfully.

                            // Set the object id from the cloud
                            Log.d(TAG, "The object id (from User) is: " + newNote.getObjectId());
                            newLocalNote.setObjectId(newNote.getObjectId());
                            Log.d(TAG, newLocalNote.toString());

                            // Add the local note to save
                            notes.add(newLocalNote);
                            itemsAdapter.notifyDataSetChanged();

                            // Show toast note saved success
                            makeToast("Note saved!");

                            // Print new array with note aded
                            Log.d("notes array isNewNote", notes.toString());

                        } else {
                            // The save failed.
                            Log.d(TAG, "User update error: " + e);
                        }
                    }
                });



            } else{
                Note newLocalNote;
                // Add note to localNoteArray
                newLocalNote = new Note(objectId, note);
                notes.add(newLocalNote);
                itemsAdapter.notifyDataSetChanged();
                Log.i("notes array !isNewNote",notes.toString() );
            }

            // Add the note to the listview, and update the listview

            // Clear textField
            mNoteEditText.setText("");
        }else{
            makeToast("There is no note!");
        }
    }

    public void makeToast(String toast){
        // Show Toast with String toast
        Toast.makeText(this, toast, Toast.LENGTH_SHORT).show();
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();
        return super.onOptionsItemSelected(item);
    }
}
