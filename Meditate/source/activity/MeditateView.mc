using Toybox.WatchUi as Ui;
using Toybox.Lang;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;
using Toybox.Timer;

class MeditateView extends Ui.View {
	private var mMeditateModel;
	private var mMainDuationRenderer;
	private var mIntervalAlertsRenderer;
	
    function initialize(meditateModel) {
        View.initialize();
        me.mMeditateModel = meditateModel;
        me.mMainDuationRenderer = null;
        me.mIntervalAlertsRenderer = null;
        me.mElapsedTime = null; 
        me.mHrStatusText = null;
        me.mMeditateIcon = null;     
    }
    
    private var mElapsedTime;
    private var mHrStatusText;    
	private var mHrStatus;
	private var mHrvIcon;
	private var mHrvText;	
    private var mMeditateIcon;
        
    private function createMeditateText(color, font, xPos, yPos, justification) {
    	return new Ui.Text({
        	:text => "",
        	:font => font,
        	:color => color,
        	:justification =>justification,
        	:locX => xPos,
        	:locY => yPos
    	});
    }
    
    private static const TextFont = Gfx.FONT_MEDIUM;
    
    private function renderBackground(dc) {				        
        dc.setColor(Gfx.COLOR_TRANSPARENT, Gfx.COLOR_BLACK);        
        dc.clear();        
    }
    
    private function renderHrStatusLayout(dc) {
    	var xPosText = dc.getWidth() / 2;
    	var yPosText = getYPosOffsetFromCenter(dc, 0);
      	me.mHrStatusText = createMeditateText(Gfx.COLOR_WHITE, TextFont, xPosText, xPosText, Gfx.TEXT_JUSTIFY_CENTER); 
      	
  	    var hrStatusX = App.getApp().getProperty("meditateActivityIconsXPos");
        var hrStatusY = getYPosOffsetFromCenter(dc, 0) + YIconOffset; 
  	    me.mHrStatus = new ScreenPicker.Icon({        
        	:font => StatusIconFonts.fontAwesomeFreeSolid,
        	:symbol => StatusIconFonts.Rez.Strings.faHeart,
        	:color=>Graphics.COLOR_RED,
        	:xPos => hrStatusX,
        	:yPos => hrStatusY
        });
    }
    
    private function renderHrvStatusLayout(dc) {
    	var hrvIconXPos = App.getApp().getProperty("meditateActivityIconsXPos");
    	var hrvTextYPos =  getYPosOffsetFromCenter(dc, 1);
        var hrvIconYPos = hrvTextYPos + YIconOffset;
        me.mHrvIcon =  new ScreenPicker.HrvIcon({
        	:xPos => hrvIconXPos,
        	:yPos => hrvIconYPos
        });
        var hrvTextXPos = hrvIconXPos + XHrvTextOffset;
        me.mHrvText = createMeditateText(Gfx.COLOR_WHITE, TextFont, hrvTextXPos, hrvTextYPos, Gfx.TEXT_JUSTIFY_LEFT); 
    }
    
    private function getYPosOffsetFromCenter(dc, lineOffset) {
    	return dc.getHeight() / 2 + lineOffset * dc.getFontHeight(TextFont);
    }
    
    private const XHrvTextOffset = 20;
    private const YIconOffset = 5;
    
    function renderLayoutElapsedTime(dc) { 	
    	var xPosCenter = dc.getWidth() / 2;
    	var yPosCenter = getYPosOffsetFromCenter(dc, -1);
    	me.mElapsedTime = createMeditateText(me.mMeditateModel.getColor(), TextFont, xPosCenter, yPosCenter, Gfx.TEXT_JUSTIFY_CENTER);
    }
                
    // Load your resources here
    function onLayout(dc) {   
        renderBackground(dc);   
        renderLayoutElapsedTime(dc);  
		        
        var durationArcRadius = dc.getWidth() / 2;
        var mainDurationArcWidth = dc.getWidth() / 4;
        me.mMainDuationRenderer = new ElapsedDuationRenderer(me.mMeditateModel.getColor(), durationArcRadius, mainDurationArcWidth);
        
        if (me.mMeditateModel.hasIntervalAlerts()) {
	        var intervalAlertsArcRadius = dc.getWidth() / 2;
	        var intervalAlertsArcWidth = dc.getWidth() / 16;
	        me.mIntervalAlertsRenderer = new IntervalAlertsRenderer(me.mMeditateModel.getSessionTime(), me.mMeditateModel.getOneOffIntervalAlerts(), 
	        	me.mMeditateModel.getRepeatIntervalAlerts(), intervalAlertsArcRadius, intervalAlertsArcWidth);    
    	}
    	  
        renderHrStatusLayout(dc);
        if (me.mMeditateModel.isHrvOn() == true) {
	        renderHrvStatusLayout(dc);
        }
    }
    
    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }
	
	private function formatHr(hr) {
		if (hr == null) {
			return "--";
		}
		else {
			return hr.toString();
		}
	}
		
	private const InvalidHeartRate = "--";
	
	private function formatHrv(hrv) {
		if (hrv == null) {
			return InvalidHeartRate;
		}
		else {
			return hrv.format("%3.0f");
		}
	}
	
    // Update the view
    function onUpdate(dc) {      
        View.onUpdate(dc);
        if (me.mMeditateIcon != null) {
        	mMeditateIcon.draw(dc);
        }
		me.mElapsedTime.setText(TimeFormatter.format(me.mMeditateModel.elapsedTime));		
		me.mElapsedTime.draw(dc);
                    
        var alarmTime = me.mMeditateModel.getSessionTime();
		me.mMainDuationRenderer.drawOverallElapsedTime(dc, me.mMeditateModel.elapsedTime, alarmTime);
		if (me.mIntervalAlertsRenderer != null) {
			me.mIntervalAlertsRenderer.drawRepeatIntervalAlerts(dc);
			me.mIntervalAlertsRenderer.drawOneOffIntervalAlerts(dc);
		}
		
		me.mHrStatusText.setText(me.formatHr(me.mMeditateModel.currentHr));
		me.mHrStatusText.draw(dc);        
     	me.mHrStatus.draw(dc);	       	
     	
 	    if (me.mMeditateModel.isHrvOn() == true) {
	        me.mHrvIcon.draw(dc);
	        me.mHrvText.setText(me.formatHrv(me.mMeditateModel.hrvSuccessive));
	        me.mHrvText.draw(dc); 
        }
    }
    

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

}
