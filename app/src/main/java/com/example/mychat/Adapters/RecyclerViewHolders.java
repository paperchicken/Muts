
package com.example.mychat.Adapters;

import android.support.v7.widget.RecyclerView;
import android.view.View;
import android.widget.TextView;

import com.example.mychat.R;

public class RecyclerViewHolders extends RecyclerView.ViewHolder{

    private static final String TAG = RecyclerViewHolders.class.getSimpleName();

    public TextView profileHeader;

    public TextView profileContent;

    public RecyclerViewHolders(final View itemView) {
        super(itemView);
        profileHeader = itemView.findViewById(R.id.heading);
        //profileContent = itemView.findViewById(R.id.profile_content);
    }
}