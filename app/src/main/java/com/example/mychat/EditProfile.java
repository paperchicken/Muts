
package com.example.mychat;

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthInvalidCredentialsException;
import com.google.firebase.auth.FirebaseAuthUserCollisionException;
import com.google.firebase.auth.FirebaseUser;

import java.util.Objects;

public class EditProfile extends Fragment {

    private FirebaseAuth mAuth;
    private FirebaseUser fbUser;
    private TextView change_name;
    private TextView change_email;
    private TextView change_password;
    //Button btn_save_changes;

    public EditProfile() {
        // Required empty public constructor
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_profile, container, false);
        return view;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
//        change_name.getBackground().setColorFilter(1, PorterDuff.Mode.SRC_IN);
        mAuth = FirebaseAuth.getInstance();
        fbUser = mAuth.getCurrentUser();

        change_name = view.findViewById(R.id.change_name);
        change_email = view.findViewById(R.id.change_email);
        change_password = view.findViewById(R.id.change_password);
        Button btn_save_changes = view.findViewById(R.id.btn_save_changes);

        btn_save_changes.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                changeEmailAddress();
            }
        });
    }

    private void changeEmailAddress() {

        String newEmail = change_email.getText().toString();

        if (TextUtils.isEmpty(newEmail)) {

            Toast.makeText(getContext(), "Please Enter Your New Email", Toast.LENGTH_SHORT).show();

        } else {

            String email = fbUser.getEmail();

            fbUser.updateEmail(newEmail).addOnCompleteListener(new OnCompleteListener<Void>() {
                    @Override
                    public void onComplete(@NonNull Task<Void> task) {

                        if (task.isSuccessful()) {

                            fbUser.sendEmailVerification().addOnCompleteListener(new OnCompleteListener<Void>() {
                                @Override
                                public void onComplete(@NonNull Task<Void> task) {

                                    Toast.makeText(getContext(), "Verification Email Sent To Your Email.. Please Verify and Login", Toast.LENGTH_LONG).show();

                                    // Logout From Firebase
                                    FirebaseAuth.getInstance()
                                            .signOut();
                                    getActivity().recreate();
                                }
                            });

                        } else {
                            try {
                                throw Objects.requireNonNull(task.getException());
                            }

                            // Invalid Email
                            catch (FirebaseAuthInvalidCredentialsException malformedEmail) {
                                Toast.makeText(getContext(), "Invalid Email...", Toast.LENGTH_LONG).show();
                            }
                            // Email Already Exists
                            catch (FirebaseAuthUserCollisionException existEmail) {
                                Toast.makeText(getContext(), "Email Used By Someone Else, Please Give Another Email...", Toast.LENGTH_LONG).show();
                            }
                            // Any Other Exception
                            catch (Exception e) {
                                Toast.makeText(getContext(), e.getMessage(), Toast.LENGTH_LONG).show();

                            }
                        }
                    }
                });

            }

        }

    }
