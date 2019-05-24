package com.example.mychat;


import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.example.mychat.Firebase.FirebaseDatabaseHelper;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.storage.FirebaseStorage;
import com.google.firebase.storage.OnProgressListener;
import com.google.firebase.storage.StorageReference;
import com.google.firebase.storage.UploadTask;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.UUID;

import static android.app.Activity.RESULT_OK;
import static com.firebase.ui.auth.AuthUI.getApplicationContext;


public class ProfileFragment extends Fragment {

    private static final String TAG = ProfileFragment.class.getSimpleName();

    private static final int GALLERY_REQUEST = 101;
    private static final int PIC_CROP = 202;
    private static final int RESULT_LOAD_IMAGE = 144;
    private static final int GALLERY_REQUEST_CODE = 2;
    private static final int CAPTURE_IMAGE = 80;
    private static final int PICK_IMAGE_REQUEST = 12314;
    private ImageView circleView;
    Uri picUri;
    private RecyclerView recyclerView;
    private LinearLayoutManager linearLayoutManager;
    private String id;
    FirebaseStorage storage;
    StorageReference storageReference;

    public ProfileFragment() {

        // Required empty public constructor
    }


    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_profile, container, false);
        circleView = view.findViewById(R.id.circleView);
        linearLayoutManager = new LinearLayoutManager(getActivity());
        FirebaseDatabaseHelper firebaseDatabaseHelper = new FirebaseDatabaseHelper();
        firebaseDatabaseHelper.isUserKeyExist(id, getActivity(), recyclerView);
        return view;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {

        super.onViewCreated(view, savedInstanceState);
        View btn_changeProfilePhoto = view.findViewById(R.id.btn_changeProfilePhoto);
        View btn_ProfileMessage = view.findViewById(R.id.btn_ProfileMessage);
        circleView = view.findViewById(R.id.circleView);
        if ( ((MainActivity) getActivity()).imageUri != null) circleView.setImageURI(((MainActivity) getActivity()).imageUri);
        TextView profile_name = view.findViewById(R.id.profile_name);
        TextView e_mail = view.findViewById(R.id.e_mail);
        String profile_name_text = FirebaseAuth.getInstance().getCurrentUser().getDisplayName();
        String e_mail_text = FirebaseAuth.getInstance().getCurrentUser().getEmail();
        profile_name.setText(profile_name_text);
        e_mail.setText(e_mail_text);


//        storage = FirebaseStorage.getInstance();
  //      storageReference = storage.getReference();

        btn_changeProfilePhoto.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Toast toast = Toast.makeText(getContext(),
                        "Данная функция пока не доступна",
                        Toast.LENGTH_SHORT);
                toast.setGravity(Gravity.BOTTOM, 0, 100);
                toast.show();
            }
        });

        btn_ProfileMessage.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Toast toast = Toast.makeText(getContext(),
                        "Данная функция пока не доступна",
                        Toast.LENGTH_SHORT);
                toast.setGravity(Gravity.BOTTOM, 0, 100);
                toast.show();
            }
        });


        circleView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent gallery = new Intent(Intent.ACTION_GET_CONTENT);
                gallery.setType("image/*");
                startActivityForResult(gallery, RESULT_LOAD_IMAGE);

            }
        });
    }


    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if(requestCode == RESULT_LOAD_IMAGE && resultCode == RESULT_OK){
            Uri imageUri = data.getData();
            circleView.setImageURI(imageUri);
            ((MainActivity) getActivity()).imageUri = imageUri;
        }

    }

}
