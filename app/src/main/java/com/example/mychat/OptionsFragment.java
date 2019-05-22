package com.example.mychat;


import android.annotation.SuppressLint;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Toast;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;

import static com.firebase.ui.auth.AuthUI.getApplicationContext;


public class OptionsFragment extends Fragment {


    public OptionsFragment() {
        // Required empty public constructor
    }

    FragmentManager myFragmentManager;
    EditProfile editProfile;

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_options, container, false);
    }

    @Override
    public void onViewCreated(@NonNull final View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        View btn_logOut = view.findViewById(R.id.btn_signOut);
        View btn_dellUser = view.findViewById(R.id.btn_dellUser);
        View btn_changeUserData = view.findViewById(R.id.btn_changeUserData);
        btn_logOut.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                if (v.getId() == R.id.btn_signOut) {
                    FirebaseAuth.getInstance()
                            .signOut();
                    getActivity().recreate();
                }
            }
        });
        btn_dellUser.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                final FirebaseUser user = FirebaseAuth.getInstance().getCurrentUser();

                // Get auth credentials from the user for re-authentication. The example below shows
                // email and password credentials but there are multiple possible providers,
                // such as GoogleAuthProvider or FacebookAuthProvider.
                FirebaseAuth.getInstance().getCurrentUser().delete();
                FirebaseAuth.getInstance().signOut();
                getActivity().recreate();
            }
        });
        btn_changeUserData.setOnClickListener(new View.OnClickListener() {
            @SuppressLint("ResourceType")
            @Override
            public void onClick(View v) {
                //getActivity().getSupportFragmentManager().beginTransaction().replace(R.id.host, new EditProfile()).commit();
                Toast toast = Toast.makeText(getApplicationContext(),
                        "Данная функция пока не доступна",
                        Toast.LENGTH_SHORT);
                toast.setGravity(Gravity.BOTTOM, 0, 100);
                toast.show();
            }
        });
    }
}

