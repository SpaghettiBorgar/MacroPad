class ConfigureWindow extends PApplet {
	private UI ui;
	boolean clicked = false;
	public ConfigureWindow() {
		super();
		PApplet.runSketch(new String[] {this.getClass().getName()}, this);
	}

	void settings() {
		size(320, 240);
	}

	void setup() {
		setupUI();
	}

	void setupUI() {
		ui = new UI();

		ui.addElement(new UIDropdown(this, 0, 0, 100, 20)
		.addOptions("foo", "bar", "meow")
		.onClick(()-> {
			clicked = true;
			println("click");
		}));
	}

	void draw() {
		this.fill(255, 0, 0);
		this.rect(20, 20, 30, 30);
		ui.draw();
	}

	void mousePressed() {
		ui.click(mouseX, mouseY, mouseButton);
	}

	void mouseReleased() {
		ui.release(mouseX, mouseY, mouseButton);
	}

	void mouseWheel(MouseEvent e) {

	}
}
