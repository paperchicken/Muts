package com.example.mychat;

public class Model {
    public String mId, mChatId, mLastMess;

    public Model(String userName, String text) {
    }

    public Model(String mId, String mChatId, String mLastMess) {
        this.mId = mId;
        this.mChatId = mChatId;
        this.mLastMess = mLastMess;
    }

    public String getmId() {
        return mId;
    }

    public String getmChatId() {
        return mChatId;
    }

    public String getmLastMess() {
        return mLastMess;
    }

    public void setmId(String mId) {
        this.mId = mId;
    }

    public void setmChatId(String mChatId) {
        this.mChatId = mChatId;
    }

    public void setmLastMess(String mLastMess) {
        this.mLastMess = mLastMess;
    }
}
