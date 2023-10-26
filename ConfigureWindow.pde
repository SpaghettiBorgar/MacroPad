class ConfigureWindow extends PApplet {
	private UI ui;
	Action action;
	int page, row, col;

	public ConfigureWindow(Action action, int page, int row, int col) {
		super();
		this.action = action;
		this.page = page;
		this.row = row;
		this.col = col;
		PApplet.runSketch(new String[] {this.getClass().getName()}, this);
	}

	void settings() {
		size(320, 260);
	}

	void setup() {
		setupUI();
	}

	void setupUI() {
		ui = new UI(this);
		UI.FormBuilder fb = ui.new FormBuilder();

		UITextField actionLabel = new UITextField(this, 100, 1)
		.placeholder("<empty>")
		.value(action.label);
		fb.addRight(new UILabel(this, "Label"))
		.addRight(actionLabel)
		.addRow();
		UIDropdown<Class<? extends Action>> actionType = new UIDropdown<Class<? extends Action>>(this)
		.addOptions((Class<? extends Action>[]) ACTION_CLASSES)
		.value(action.getClass());
		fb.addRight(new UILabel(this, "Action Type"))
		.addRight(actionType)
		.addRow(16);

		LinkedHashMap<String, Class<?>> props = action.getProperties();
		HashMap<String, HoldsValue> propElems = new HashMap<>();
		propElems.put("label", actionLabel);

		for(String prop : props.keySet()) {
			if(prop == "label")
				continue;
			Class<?> type = props.get(prop);
			HoldsValue e;
			if (type == String.class) {
				e = new UITextField(this, 200, 6)
				.value(action.getProperty(prop))
				.placeholder(prop)
				.lineNumbers(1);
				propElems.put(prop, e);
				fb.addRight(new UILabel(this, prop))
				.addRow();
			} else if(type.equals(Integer.TYPE)) {
				e = new UINumberInput(this)
				.value(action.getProperty(prop));
				fb.addRight(new UILabel(this, prop));
			} else if(type.isEnum()) {
				Class<? extends Enum<?>> etype = (Class<? extends Enum<?>>) type;
				e = new UIDropdown<Enum>(this)
				.addOptions(etype.getEnumConstants());
				fb.addRight(new UILabel(this, prop));
			} else {
				println("Unimplemented property type " + type);
				continue;
			}
			propElems.put(prop, e);
			fb.addRight((UIElement) e);
			fb.addRow();
		}
		fb.addRow(8)
		.addRight(new UIButton(this)
		.wh(60, 20)
		.label("Cancel")
		.onRelease(()-> {
			this.closeWindow();
		}))
		.addRight(0, new UIButton(this)
		.wh(40, 20)
		.label("OK")
		.onRelease(()-> {
			try {
				action = actionType.value().getConstructor(KeyPad.class).newInstance(KeyPad.this);
				for (String prop : propElems.keySet()) {
					action.setProperty(prop, propElems.get(prop).value());
					println(prop, action.getProperty(prop));
				}
				actions.addAction(page, row, col, action);
				this.closeWindow();
			} catch(Exception e) {
				e.printStackTrace();
			}
		}))
		.addRow();
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

	void closeWindow() {
		surface.setVisible(false);
		dispose();
	}
}
