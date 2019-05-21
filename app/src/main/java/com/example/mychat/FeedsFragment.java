package com.example.mychat;

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.design.widget.FloatingActionButton;
import android.support.v4.app.Fragment;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.firebase.ui.database.FirebaseRecyclerAdapter;
import com.firebase.ui.database.FirebaseRecyclerOptions;
import com.firebase.ui.database.SnapshotParser;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.Query;

import java.util.HashMap;
import java.util.Map;

public class FeedsFragment extends Fragment {

    private RecyclerView recyclerViewFeed;
    private FloatingActionButton addFeedButton;
    private LinearLayoutManager linearLayoutManager;
    private FirebaseRecyclerAdapter adapter;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.feeds_fragment, container, false);
        return view;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        recyclerViewFeed = view.findViewById(R.id.recyclerViewFeed);
        addFeedButton = view.findViewById(R.id.btn_add_feed);
        linearLayoutManager = new LinearLayoutManager(getContext());
        recyclerViewFeed.setLayoutManager(linearLayoutManager);
        addFeedButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                DatabaseReference databaseReference = FirebaseDatabase.getInstance().getReference().child("feedList")
                        .child(FirebaseAuth
                                .getInstance()
                                .getCurrentUser()
                                .getUid()).push();
                Map<String, Object> map = new HashMap<>();
                map.put("UserName", FirebaseAuth.getInstance().getCurrentUser().getDisplayName());
                map.put("text", "Text");

                databaseReference.setValue(map);
            }
        });
        /*FirebaseRecyclerAdapter fra = new FirebaseRecyclerAdapter() {
            @Override
            protected void populateViewHolder(RecyclerView.ViewHolder viewHolder, Object model, int position) {


        }*/

        fetch();
    }

    private void fetch() {
        Query query = FirebaseDatabase.getInstance()
                .getReference()
                .child("feedList")
                .child(FirebaseAuth
                        .getInstance()
                        .getCurrentUser()
                        .getUid());
        FirebaseRecyclerOptions<Model> options =
                new FirebaseRecyclerOptions.Builder<Model>()
                        .setQuery(query, new SnapshotParser<Model>() {
                            @NonNull
                            @Override
                            public Model parseSnapshot(@NonNull DataSnapshot snapshot) {
                                Log.wtf("tag", "displayFeed1: " +snapshot.getRef().toString());

                                return new Model(
                                        snapshot.child("UserName").getValue().toString(),
                                        snapshot.child("text").getValue().toString());
                            }
                        })
                        .build();
        adapter = new FirebaseRecyclerAdapter<Model, FeedsFragment.ViewHolder>(options) {
            @Override
            protected void onBindViewHolder(@NonNull ViewHolder holder, int position, @NonNull Model model) {

            }

            @NonNull
            @Override
            public FeedsFragment.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
                View view = LayoutInflater.from(parent.getContext())
                        .inflate(R.layout.feeds_list_item, parent, false);
                view.setClipToOutline(true);
                return new ViewHolder(view);
            }
        };
        recyclerViewFeed.setAdapter(adapter);
    }


    public class ViewHolder extends RecyclerView.ViewHolder {
        public LinearLayout feed_root;
        public TextView feed_userName;
        public TextView feed_text;

        public ViewHolder(View itemView) {
            super(itemView);
            feed_root = itemView.findViewById(R.id.feed_root);
            feed_userName = itemView.findViewById(R.id.feed_userId);
            String userName = FirebaseAuth.getInstance().getCurrentUser().getDisplayName();
            feed_userName.setText(userName);

            feed_text = itemView.findViewById(R.id.feed_text);
        }
    }

    @Override
    public void onStart() {
        super.onStart();
        adapter.startListening();
        Log.wtf("tag", "onStart: ");
    }

    @Override
    public void onStop() {
        super.onStop();
        Log.wtf("tag", "onStop: ");
        adapter.stopListening();
    }
}
