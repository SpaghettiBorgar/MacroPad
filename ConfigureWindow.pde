class ConfigureWindow extends PApplet {
	private UI ui;
	private UI.FormBuilder fb;
	private HashMap<String, HoldsValue> propElems;
	Action origaction;
	Action action;
	Consumer<Action> callback;

	public ConfigureWindow(Action action, Consumer<Action> callback) {
		super();
		this.origaction = action;
		this.action = this.origaction;
		this.callback = callback;
		PApplet.runSketch(new String[] {this.getClass().getName()}, this);
	}

	void settings() {
		size(320, 260);
	}

	void setup() {
		setupUI();
	}

	private HashMap<String, HoldsValue> addPropertyElements(Action action, UI.FormBuilder fb) {

		LinkedHashMap<String, Class<?>> props = action.getProperties();
		HashMap<String, HoldsValue> propElems = new HashMap<>();

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
		return propElems;
	}

	void setupUI() {
		ui = new UI(this);
		fb = ui.new FormBuilder();

		UITextField actionLabel = new UITextField(this, 100, 1)
		.placeholder("<empty>")
		.value(action.label);

		UIDropdown<Class<? extends Action>> actionType = new UIDropdown<Class<? extends Action>>(this)
		.addOptions((Class<? extends Action>[]) ACTION_CLASSES);

		actionType.onChange(() -> {
			if(actionType.value() == origaction.getClass())
				action = origaction;
			else {
				try {
					action = actionType.value().getConstructor(KeyPad.class).newInstance(KeyPad.this);
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
			ui = new UI(this);
			fb = ui.new FormBuilder();
			fb.addRight(new UILabel(this, "Label"))
			.addRight(actionLabel)
			.addRow();
			fb.addRight(new UILabel(this, "Action Type"))
			.addRight(actionType)
			.addRow(16);
			propElems = addPropertyElements(action, fb);
			propElems.put("label", actionLabel);

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
					callback.accept(action);
					this.closeWindow();
				} catch(Exception e) {
					e.printStackTrace();
				}
			}))
			.addRow();
		});

		actionType.value(action.getClass());
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
