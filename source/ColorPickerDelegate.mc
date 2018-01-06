using Toybox.WatchUi as Ui;

class ColorPickerDelegate extends ScreenPickerDelegate {

	function initialize(colors, onColorSelected) {
		ScreenPickerDelegate.initialize(colors, onColorSelected);		
	}
	
	function createScreenPickerView() {
		return new ScreenPickerView(me.mColors[me.mSelectedColorIndex]);
	}
}