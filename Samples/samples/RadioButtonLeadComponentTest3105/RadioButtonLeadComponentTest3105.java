package com.codename1.samples;


import static com.codename1.ui.CN.*;
import com.codename1.ui.Display;
import com.codename1.ui.*;
import com.codename1.ui.Form;
import com.codename1.ui.Dialog;
import com.codename1.ui.Label;
import com.codename1.ui.plaf.UIManager;
import com.codename1.ui.util.Resources;
import com.codename1.io.Log;
import com.codename1.ui.Toolbar;
import java.io.IOException;
import com.codename1.ui.layouts.BoxLayout;
import com.codename1.io.NetworkEvent;
import com.codename1.ui.ButtonGroup;
import com.codename1.ui.ComponentGroup;
import com.codename1.ui.Container;
import com.codename1.ui.layouts.BorderLayout;

/**
 * This file was generated by <a href="https://www.codenameone.com/">Codename One</a> for the purpose 
 * of building native mobile applications using Java.
 */
public class RadioButtonLeadComponentTest3105 {

    private Form current;
    private Resources theme;

    public void init(Object context) {
        // use two network threads instead of one
        updateNetworkThreadCount(2);

        theme = UIManager.initFirstTheme("/theme");

        // Enable Toolbar on all Forms by default
        Toolbar.setGlobalToolbar(true);

        // Pro only feature
        Log.bindCrashProtection(true);

        addNetworkErrorListener(err -> {
            // prevent the event from propagating
            err.consume();
            if(err.getError() != null) {
                Log.e(err.getError());
            }
            Log.sendLogAsync();
            Dialog.show("Connection Error", "There was a networking error in the connection to " + err.getConnectionRequest().getUrl(), "OK", null);
        });        
    }
    
    public void start() {
        if(current != null){
            current.show();
            return;
        }
        Form hi = new Form("Lead component breaks ComponentGroup", BoxLayout.y());

        ButtonGroup group = new ButtonGroup();
        ComponentGroup cgroup = new ComponentGroup();
        Label editFieldLabel = new Label("");
        Container visibleField = BorderLayout.centerCenterEastWest(cgroup, editFieldLabel, null);
        RadioButton r1 = new RadioButton("R1");
        group.add(r1);
        cgroup.add(r1);
        RadioButton r2 = new RadioButton("R2");
        group.add(r2);
        cgroup.add(r2);
        hi.add(visibleField);

        ButtonGroup group2 = new ButtonGroup();
        ComponentGroup cgroup2 = new ComponentGroup();
        Label editFieldLabel2 = new Label("EDIT2");
        Container visibleField2 = BorderLayout.centerCenterEastWest(cgroup2, editFieldLabel2, null);
        RadioButton r3 = new RadioButton("R3");
        group2.add(r3);
        cgroup2.add(r3);
        RadioButton r4 = new RadioButton("R4");
        group2.add(r4);
        cgroup2.add(r4);
        hi.add(visibleField2);

        //What causes the problem:
        cgroup2.setBlockLead(true);
        visibleField2.setLeadComponent(cgroup2); //making the ComponentGroup lead makes it impossible to select the radio buttons

        hi.show();
    }

    public void stop() {
        current = getCurrentForm();
        if(current instanceof Dialog) {
            ((Dialog)current).dispose();
            current = getCurrentForm();
        }
    }
    
    public void destroy() {
    }

}
