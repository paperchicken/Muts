package com.jtmoc.muts;

public class Post {
    public String pUserName, pText;

    public Post(String pUserName, String pText) {
        this.pUserName = pUserName;
        this.pText = pText;
    }

    public String getpText() {
        return pText;
    }

    public String getpUserName() {
        return pUserName;
    }

    public void setpText(String pText) {
        this.pText = pText;
    }

    public void setpUserName(String pUserName) {
        this.pUserName = pUserName;
    }
}
