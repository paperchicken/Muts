package com.example.mychat;


import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.example.mychat.Firebase.FirebaseDatabaseHelper;
import com.google.firebase.auth.FirebaseAuth;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Date;


public class ProfileFragment extends Fragment {

    private static final String TAG = ProfileFragment.class.getSimpleName();

    private static final int GALLERY_REQUEST = 101;
    private static final int PIC_CROP = 202;
    private static final int RESULT_LOAD_IMAGE = 144;
    private static final int CAMERA_REQUEST_CODE = 1;
    private static final int GALLERY_REQUEST_CODE = 2;
    private static final int CAPTURE_IMAGE = 80;
    private ImageView circleView;
    Uri picUri;
    private RecyclerView recyclerView;
    private LinearLayoutManager linearLayoutManager;
    private String id;
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
        circleView = view.findViewById(R.id.circleView);
        TextView profile_name = view.findViewById(R.id.profile_name);
        TextView e_mail = view.findViewById(R.id.e_mail);
        String profile_name_text = FirebaseAuth.getInstance().getCurrentUser().getDisplayName();
        String e_mail_text = FirebaseAuth.getInstance().getCurrentUser().getEmail();
        profile_name.setText(profile_name_text);
        e_mail.setText(e_mail_text);

        circleView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent i = new Intent(android.provider.MediaStore.ACTION_IMAGE_CAPTURE);

                File file = getOutputMediaFile(1);
                picUri = Uri.fromFile(file); // create
                i.putExtra(MediaStore.EXTRA_OUTPUT,picUri); // set the image file
                startActivityForResult(i, CAPTURE_IMAGE);
            }
        });
    }

    private  File getOutputMediaFile(int type){
        File mediaStorageDir = new File(Environment.getExternalStoragePublicDirectory(
                Environment.DIRECTORY_PICTURES), "MyApplication");

        /**Create the storage directory if it does not exist*/
        if (! mediaStorageDir.exists()){
            if (! mediaStorageDir.mkdirs()){
                return null;
            }
        }

        /**Create a media file name*/
        @SuppressLint("SimpleDateFormat") String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
        File mediaFile;
        if (type == 1){
            mediaFile = new File(mediaStorageDir.getPath() + File.separator +
                    "IMG_"+ timeStamp + ".png");
        } else {
            return null;
        }

        return mediaFile;
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (resultCode == Activity.RESULT_OK) {
            Intent i;
            switch (requestCode) {
                case CAPTURE_IMAGE:
                    //THIS IS YOUR Uri
                    Uri uri= picUri;
                    break;
            }
        }
    }
}
