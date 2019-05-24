package com.jtmoc.muts;

import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.design.widget.FloatingActionButton;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.RecyclerView;
import android.text.format.DateFormat;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.TextView;

import com.firebase.ui.database.FirebaseRecyclerAdapter;
import com.firebase.ui.database.FirebaseRecyclerOptions;
import com.firebase.ui.database.SnapshotParser;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.Query;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;

public class ChatActivity extends AppCompatActivity {
    String chatId;
    FirebaseRecyclerAdapter<ChatMessage, ViewHolder> adapter;
    RecyclerView recyclerView;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_chat);
        recyclerView = findViewById(R.id.recyclerChat);
        Intent intent = getIntent();
        chatId = intent.getStringExtra("chatId");
        FloatingActionButton fab =
                findViewById(R.id.fab);

        fab.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                EditText input = findViewById(R.id.input);

                // Read the input field and push a new instance
                // of ChatMessage to the Firebase database
                DatabaseReference db= FirebaseDatabase.getInstance()
                        .getReference()
                        .child("chats")
                        .child(chatId)
                        .push();
                Map<String, Object> map = new HashMap<>();
                map.put("messageText", input.getText().toString().trim());
                map.put("messageUser", FirebaseAuth.getInstance()
                        .getCurrentUser()
                        .getDisplayName());
                map.put("messageTime",new Date().getTime());
                db.setValue(map);

                // Clear the input
                input.setText("");
            }
        });
        displayChatMessages();
    }


    void displayChatMessages() {
        Query query = FirebaseDatabase.getInstance()
                .getReference()
                .child("chats")
                .child(chatId);
        Log.wtf("tag", "displayChatMessages: " +query.getRef().toString());
        FirebaseRecyclerOptions<ChatMessage> options =
                new FirebaseRecyclerOptions.Builder<ChatMessage>()
                        .setQuery(query, new SnapshotParser<ChatMessage>() {
                            @NonNull
                            @Override
                            public ChatMessage parseSnapshot(@NonNull DataSnapshot snapshot) {
                                Log.wtf("tag", "displayChatMessages: " +snapshot.getRef().toString());
                                return new ChatMessage(snapshot.child("messageText").getValue().toString(),
                                        snapshot.child("messageUser").getValue().toString(),
                                        Long.valueOf(snapshot.child("messageTime").getValue().toString()));
                            }
                        })
                        .build();
        adapter = new FirebaseRecyclerAdapter<ChatMessage, ChatActivity.ViewHolder>(options){
            @NonNull
            @Override
            public ChatActivity.ViewHolder onCreateViewHolder(@NonNull ViewGroup viewGroup, int i) {
                View view = LayoutInflater.from(viewGroup.getContext())
                        .inflate(R.layout.message, viewGroup, false);
                view.setClipToOutline(true);
                return new ChatActivity.ViewHolder(view);
            }

            @Override
            protected void onBindViewHolder(@NonNull ChatActivity.ViewHolder holder, int position, @NonNull ChatMessage model) {
                    holder.setText(model.getMessageText());
                    holder.setTime(model.getMessageTime());
                    holder.setUsername(model.getMessageUser());
            }
        };

        adapter.startListening();
        Log.wtf("tag", "displayChatMessages: " + adapter.getSnapshots().toString() );
        recyclerView.setAdapter(adapter);
    }

     public class ViewHolder extends RecyclerView.ViewHolder {
        public TextView text;
        public TextView username;
        public TextView time;

        public ViewHolder(View itemView) {
            super(itemView);
            text = itemView.findViewById(R.id.message_text);
            username = itemView.findViewById(R.id.message_user);
            time = itemView.findViewById(R.id.message_time);
        }

        public void setUsername(String string) {
            username.setText(string);
        }

        public void setText(String string){
            text.setText(string);
        }

        public void setTime(long l) {
            time.setText(DateFormat.format("dd-MM-yyyy (HH:mm:ss)", l));
        }
    }

    @Override
    public void onStart() {
        super.onStart();
        Log.wtf("tag", "onStart: 1");
        adapter.startListening();
    }

    @Override
    public void onStop() {
        super.onStop();
        adapter.stopListening();
    }
}

