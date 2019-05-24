package com.jtmoc.muts;

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
import android.widget.EditText;
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


public class ChatListFragment extends Fragment {
    private RecyclerView recyclerView;
    private FloatingActionButton addChatButton;
    private LinearLayoutManager linearLayoutManager;
    private FirebaseRecyclerAdapter adapter;
    EditText et;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_chat_list, null);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        recyclerView = view.findViewById(R.id.listChat);
        addChatButton = view.findViewById(R.id.addChatButton);
        linearLayoutManager = new LinearLayoutManager(getContext());
        recyclerView.setLayoutManager(linearLayoutManager);
        et = view.findViewById(R.id.id);
        addChatButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                DatabaseReference databaseReference = FirebaseDatabase.getInstance().getReference().child("chatList")
                        .child(((MainActivity) getActivity()).getChatId())
                        .push();

                Map<String, Object> map = new HashMap<>();
                map.put("chatId", databaseReference.getKey());
                map.put("chatName", FirebaseAuth.getInstance().getCurrentUser().getDisplayName());
                map.put("lastMessage", et.getText().toString());
                et.setText("");

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
                .child("chatList")
                .child(((MainActivity) getActivity()).getChatId());
        FirebaseRecyclerOptions<Model> options =
                new FirebaseRecyclerOptions.Builder<Model>()
                        .setQuery(query, new SnapshotParser<Model>() {
                            @NonNull
                            @Override
                            public Model parseSnapshot(@NonNull DataSnapshot snapshot) {
                                Log.wtf("tag", "displayChatMessages1: " +snapshot.getRef().toString());

                                return new Model(snapshot.child("chatId").getValue().toString(),
                                        snapshot.child("chatName").getValue().toString(),
                                        snapshot.child("lastMessage").getValue().toString());
                            }
                        })
                        .build();
        adapter = new FirebaseRecyclerAdapter<Model, ViewHolder>(options) {
            @NonNull
            @Override
            public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
                View view = LayoutInflater.from(parent.getContext())
                        .inflate(R.layout.chat_list_item, parent, false);
                view.setClipToOutline(true);
                return new ViewHolder(view);
            }


            @Override
            protected void onBindViewHolder(ViewHolder holder, final int position, final Model model) {
                holder.setCharId(model.getmChatId());
                holder.setLastChatMessage(model.getmLastMess());




            }

        };
        recyclerView.setAdapter(adapter);
    }


    public class ViewHolder extends RecyclerView.ViewHolder {
        public LinearLayout root;
        public TextView txtTitle;
        public TextView txtDesc;

        public ViewHolder(View itemView) {
            super(itemView);
            root = itemView.findViewById(R.id.list_root);
            txtTitle = itemView.findViewById(R.id.list_chatId);
            txtDesc = itemView.findViewById(R.id.list_last_message);
        }

        public void setCharId(String string) {
            txtTitle.setText(string);
        }


        public void setLastChatMessage(String string) {
            txtDesc.setText(string);
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
