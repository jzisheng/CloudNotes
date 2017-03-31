package com.bignerdranch.android.finalproject374;

import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Parcelable;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;

import com.parse.LogInCallback;
import com.parse.Parse;
import com.parse.ParseException;
import com.parse.ParseUser;
import com.parse.SignUpCallback;

public class LoginRegistration extends AppCompatActivity {
    Button mTopButton;
    Button mBottomButton;
    EditText mUsername;
    EditText mPassword;
    ParseUser mUser;
    public final static String EXTRA_PARSE_USER = "com.bignerdranch.android.finalproject374.USER";

    Boolean mLoginMode = true;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        // Initialize Parse //
        try{
            Parse.initialize(new Parse.Configuration.Builder(this)
                    .applicationId("e9274DMCm9201")
                    .server("http://23.253.48.144:1337/parse")
                    .build()
            );
        } catch(Exception e){
            e.printStackTrace();
        }


        // See if a user is already logged in
        mUser = ParseUser.getCurrentUser();
        if(mUser != null){
            // User is logged in
            userLogin();
        } else{
            // Go back to login screen
        }


        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login_registration);
        Toolbar toolbar = (Toolbar) findViewById(R.id.login_toolbar);
        setSupportActionBar(toolbar);

        // Connect all the buttons
        mTopButton = (Button) findViewById(R.id.login_button);
        mBottomButton = (Button) findViewById(R.id.login_register_button);
        mUsername = (EditText) findViewById(R.id.username_edit_text);
        mPassword = (EditText) findViewById(R.id.password_edit_text);

        // Set the subtitle of the login page
        android.support.v7.app.ActionBar actionBar = getSupportActionBar();
        actionBar.setSubtitle("Welcome back!");

        mTopButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Log.d("Button","Button pressed");
                final View view = v;

                //if in sign up mode
                if(!mLoginMode){
                    Log.d("signingup","signup");
                    ParseUser user = new ParseUser();
                    user.setUsername(mUsername.getText().toString());
                    user.setPassword(mPassword.getText().toString());

                    user.signUpInBackground(new SignUpCallback() {
                        public void done(ParseException e) {
                            if (e == null) {
                                // Hooray! Let them use the app now.
                                Log.d("login register", "registered!");
                                InputMethodManager imm = (InputMethodManager)getSystemService(Context.INPUT_METHOD_SERVICE);
                                imm.hideSoftInputFromWindow(mPassword.getWindowToken(), 0);
                                createSnackBar(view, "Signed up, return to login page to login!");

                            } else {
                                // Sign up didn't succeed. Look at the ParseException
                                // to figure out what went wrong
                                String error = e.getMessage().toString();
                                InputMethodManager imm = (InputMethodManager)getSystemService(Context.INPUT_METHOD_SERVICE);
                                imm.hideSoftInputFromWindow(mPassword.getWindowToken(), 0);
                                createSnackBar(view, error);

                            }
                        }
                    });

                }
                if(mLoginMode){
                    ParseUser.logInInBackground(mUsername.getText().toString(),
                            mPassword.getText().toString(), new LogInCallback() {
                        public void done(ParseUser user, ParseException e) {
                            if (user != null) {
                                // Hooray! The user is logged in.
                                InputMethodManager imm = (InputMethodManager)getSystemService(Context.INPUT_METHOD_SERVICE);
                                imm.hideSoftInputFromWindow(mPassword.getWindowToken(), 0);
                                createSnackBar(view, "Success logging in!");

                                // Start myCloud Activity
                                userLogin();

                            } else {
                                // Signup failed. Look at the ParseException to see what happened.
                                InputMethodManager imm = (InputMethodManager)getSystemService(Context.INPUT_METHOD_SERVICE);
                                imm.hideSoftInputFromWindow(mPassword.getWindowToken(), 0);
                                createSnackBar(view, e.getMessage().toString());
                            }
                        }
                    });
                }
            }
        });

        mBottomButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                switchLoginMode(mLoginMode);
            }
        });
    }

    public void userLogin(){
        Intent intent = new Intent(this, MainActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
        try {
            // Putting user as extra, not necessary(user is logged in)
            // intent.putExtra(EXTRA_PARSE_USER, (Parcelable) ParseUser.getCurrentUser());
            startActivity(intent);
            finish();
        } catch(Exception e){
            createSnackBar(this.findViewById(R.id.activity_login_and_registration),
                    e.getMessage());
        }
    }

    public void createSnackBar(View view, String message){
        Snackbar.make(view, message, Snackbar.LENGTH_LONG)
                .setAction("Action", null).show();
    }


    public void alertDialog(){
        new AlertDialog.Builder(this.getApplicationContext())
                .setTitle("Delete entry")
                .setMessage("Are you sure you want to delete this entry?")
                .setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        // continue with delete
                    }
                })
                .setNegativeButton(android.R.string.no, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        // do nothing
                    }
                })
                .setIcon(android.R.drawable.ic_dialog_alert)
                .show();
    }

    public void switchLoginMode(boolean loginMode){
        if(loginMode) {
            mTopButton.setText(R.string.activity_register_button);
            mBottomButton.setText(R.string.activity_login_button);

        }
        else{
            mTopButton.setText(R.string.activity_login_button);
            mBottomButton.setText(R.string.activity_register_button);
        }
        mLoginMode = !loginMode;
        Log.i("login mode",mLoginMode.toString());
    }

}
