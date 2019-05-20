package com.example.mychat;

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.design.widget.BottomNavigationView;
import android.support.v4.app.Fragment;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.MenuItem;
import android.widget.Toast;

import com.firebase.ui.auth.AuthUI;
import com.google.firebase.auth.FirebaseAuth;

public class MainActivity extends AppCompatActivity {

    private static final int SIGN_IN_REQUEST_CODE = 5;
    private static final String TAG = "WTF";
    Toolbar toolbar;

    private BottomNavigationView.OnNavigationItemSelectedListener mOnNavigationItemSelectedListener
            = new BottomNavigationView.OnNavigationItemSelectedListener() {

        @Override
        public boolean onNavigationItemSelected(@NonNull MenuItem item) {
            Fragment fragment = null;
            Log.wtf(TAG, "NavigationItemSelected: start");
            switch (item.getItemId()) {
                case R.id.navigation_feeds:
                    fragment = new FeedsFragment();
                    toolbar.setTitle("Лента");
                    break;
                case R.id.navigation_chat:
                    fragment = new ChatListFragment();
                    toolbar.setTitle("Чаты");
                    break;

                case R.id.navigation_profile:
                    fragment = new ProfileFragment();
                    toolbar.setTitle("Профиль");
                    break;

                case R.id.navigation_options:
                    fragment = new OptionsFragment();
                    toolbar.setTitle("Настройки");
                    break;
            }
            Log.wtf(TAG, "nNavigationItemSelected: stop");
            return loadFragment(fragment);
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        toolbar = findViewById(R.id.toolbar);
        BottomNavigationView navigation = findViewById(R.id.navigation);
        navigation.setSelectedItemId(R.id.navigation_chat);
        navigation.setOnNavigationItemSelectedListener(mOnNavigationItemSelectedListener);
        if (FirebaseAuth.getInstance().getCurrentUser() == null) {
            // Start sign in/sign up activity

            startActivityForResult(
                    AuthUI.getInstance()
                            .createSignInIntentBuilder()
                            .build(),
                    SIGN_IN_REQUEST_CODE
            );
        } else {
            // User is already signed in. Therefore, display
            // a welcome Toast
            Toast.makeText(this,
                    "Hello " + FirebaseAuth.getInstance()
                            .getCurrentUser()
                            .getDisplayName(),
                    Toast.LENGTH_LONG)
                    .show();
            //startActivity(new Intent(this, ChatActivity.class));

            loadFragment(new FeedsFragment());
        }

    }


    private boolean loadFragment(Fragment fragment) {
        //switching fragment
        if (fragment != null) {
            getSupportFragmentManager()
                    .beginTransaction()
                    .replace(R.id.host, fragment)
                    .commit();
            Log.wtf(TAG, "loadFragment: done");
            return true;
        }
        return false;
    }

}
