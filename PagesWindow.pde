class PagesWindow extends PApplet {
	private UI ui;
	ActionMatrix actions;

	public PagesWindow(ActionMatrix actions) {
		super();
		this.actions = actions;
		PApplet.runSketch(new String[] {this.getClass().getName()}, this);
	}

	void settings() {
		size(300, 330);
	}

	void setup() {

		ui = new UI(this);
		UIShuffleList<String> pagelist = new UIShuffleList<String>(this)
		.xywh(10, 10, 280, 240);
		ui.addElement(pagelist);
		HashMap<UIShuffleList<String>.ListItem<String>, Integer> mapping = new HashMap<>();

		for(int i = 0; i < actions.numPages(); i++) {
			mapping.put(pagelist.addItem(actions.pageNames.get(i)), i);
		}

		ui.addElement(new UIButton(this).label("+").xywh(10, 250, 280, 30).onRelease(() -> {
			mapping.put(pagelist.addItem("Page " + (pagelist.numItems() + 1)), -1);
		}));
		ui.addElement(new UIButton(this).label("Cancel").xywh(10, 290, 80, 30).onRelease(() -> {
			closeWindow();
		}));
		ui.addElement(new UIButton(this).label("Save").xywh(100, 290, 80, 30).onRelease(() -> {
			ArrayList<Action[][]> newPages = new ArrayList<>(Collections.nCopies(pagelist.numItems(), null));
			ArrayList<String> newPageNames = new ArrayList<>(Collections.nCopies(pagelist.numItems(), null));
			for(UIShuffleList<String>.ListItem<String> item : mapping.keySet()) {
				int sourceIndex = mapping.get(item);
				if(sourceIndex == -1) {
					sourceIndex = actions.numPages();
					actions.addPage();
				}
				println(actions.pages.size());
				newPages.set(item.index, actions.pages.get(sourceIndex));
				newPageNames.set(item.index, item.value());
			}
			actions.pages = newPages;
			actions.pageNames = newPageNames;
			closeWindow();
		}));
	}

	void draw() {
		ui.draw();
	}

	void mousePressed() {
		ui.click(mouseX, mouseY, mouseButton);
	}

	void mouseReleased() {
		ui.release(mouseX, mouseY, mouseButton);
	}

	void mouseWheel(MouseEvent e) {
		ui.scroll(mouseX, mouseY, e.getCount());
	}

	void keyPressed() {
		ui.keyDown(mouseX, mouseY, key);
		if(key == ESC)
			key = 0;
	}

	void keyReleased() {
		ui.keyUp(mouseX, mouseY, key);
	}

	void mouseMoved() {
		ui.mouseMove(mouseX, mouseY, false);
	}

	void mouseDragged() {
		ui.mouseMove(mouseX, mouseY, true);
	}

	void closeWindow() {
		surface.setVisible(false);
		dispose();
	}
}
