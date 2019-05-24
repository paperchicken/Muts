package com.jtmoc.muts.Adapters;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.v7.widget.RecyclerView;
import android.view.ViewGroup;

import com.jtmoc.muts.ProfileFragment;

import java.util.List;

public class RecyclerViewAdapter extends RecyclerView.Adapter<RecyclerViewHolders> {

    private List<ProfileFragment> user;

    protected Context context;

    public RecyclerViewAdapter(Context context, List<ProfileFragment> user) {
        this.user = user;
        this.context = context;
    }

    //@Override
    //public RecyclerViewHolders onCreateViewHolder(ViewGroup parent, int viewType) {
    //    RecyclerViewHolders viewHolder = null;
    //    View layoutView = LayoutInflater.from(parent.getContext()).inflate(R.layout.profile_list, parent, false);
    //    viewHolder = new RecyclerViewHolders(layoutView);
    //    return viewHolder;
    //}

    @NonNull
    @Override
    public RecyclerViewHolders onCreateViewHolder(@NonNull ViewGroup viewGroup, int i) {
        return null;
    }

    @Override
    public void onBindViewHolder(RecyclerViewHolders holder, int position) {
        //holder.profileHeader.setText(user.get(position).getHeader());
        //holder.profileContent.setText(user.get(position).getProfileContent());
    }

    @Override
    public int getItemCount() {
        return this.user.size();
    }

}